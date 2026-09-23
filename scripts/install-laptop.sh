#!/usr/bin/env bash
# Install the `laptop` host onto the internal 1 TB NVMe, replacing Pop!_OS.
# Run it FROM THE BOOTED USB NIXOS (it needs nixos-install).
#
#   bash scripts/install-laptop.sh                 # full install
#   bash scripts/install-laptop.sh --install-only  # resume at step 4
#
# ERASES THE WHOLE TARGET DISK. Windows lives on the other NVMe and is
# never touched: the script refuses any disk holding a BitLocker volume,
# and any disk the running system boots from.
set -euo pipefail

TARGET="${TARGET:-/dev/nvme0n1}"   # Pop!_OS disk; override with TARGET=...
SYS_SIZE="${SYS_SIZE:-200GiB}"     # system partition; /home gets the rest

INSTALL_ONLY=false
[ "${1:-}" = "--install-only" ] && INSTALL_ONLY=true

REPO="$(cd "$(dirname "$0")/.." && pwd)"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "run this script as your user, not as root"
[ -f "$REPO/flake.nix" ] || die "flake.nix not found in $REPO"
command -v nixos-install >/dev/null || die "run this script from the NixOS USB system"

for command in parted cryptsetup mkfs.fat mkfs.btrfs; do
  command -v "$command" >/dev/null \
    || die "missing command: $command (see docs/install-laptop.md)"
done

if [ "$INSTALL_ONLY" = true ]; then
  findmnt /mnt/boot >/dev/null && findmnt /mnt/home >/dev/null \
    || die "the disk is not mounted on /mnt (rerun without --install-only)"
else

step "1. Checking target disk ($TARGET)"
[ -b "$TARGET" ] || die "$TARGET does not exist"

[ ! -e /dev/mapper/laptop-cryptroot ] \
  || die "/dev/mapper/laptop-cryptroot is already active; close the old volume before retrying"
[ ! -e /dev/mapper/laptop-crypthome ] \
  || die "/dev/mapper/laptop-crypthome is already active; close the old volume before retrying"

# Never touch the disk the running system boots from (the USB drive).
# lsblk lists the whole tree of TARGET, including dm/LUKS devices, so a
# running root sitting anywhere under it is caught.
running_src="$(findmnt -no SOURCE / || true)"
if [ -n "$running_src" ] && lsblk -npo NAME "$TARGET" | grep -qxF "$running_src"; then
  die "$TARGET contains the running system"
fi

# Never touch the Windows disk.
if lsblk -no FSTYPE "$TARGET" | grep -qi bitlocker; then
  die "$TARGET contains a BitLocker volume (Windows); aborting"
fi

lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$TARGET"
printf '\n\033[1;31mALL CONTENTS OF %s (Pop!_OS) WILL BE ERASED.\033[0m\n' "$TARGET"
echo "System: $SYS_SIZE   /home: the rest of the disk"
read -rp "Type ERASE to continue: " answer
[ "$answer" = "ERASE" ] || die "cancelled"

step "2. Partitioning"
for part in "$TARGET"?*; do
  [ -b "$part" ] && sudo umount "$part" 2>/dev/null || true
done
sudo swapoff -a || true
sudo wipefs -a "$TARGET"
sudo parted -s "$TARGET" -- \
  mklabel gpt \
  mkpart LAPBOOT fat32 1MiB 1GiB \
  set 1 esp on \
  mkpart LAPCRYPT 1GiB "$SYS_SIZE" \
  mkpart LAPHOME "$SYS_SIZE" 100%
sudo udevadm settle

# NVMe partitions are p1, p2, p3
case "$TARGET" in
  *[0-9]) P="${TARGET}p" ;;
  *) P="$TARGET" ;;
esac
BOOT_PART="${P}1"; SYS_PART="${P}2"; HOME_PART="${P}3"
for p in "$BOOT_PART" "$SYS_PART" "$HOME_PART"; do
  [ -b "$p" ] || die "partition $p not found"
done

step "3. Encryption and formatting"
echo "One passphrase for both volumes (system and /home)."
echo "systemd caches it: you only type it once at boot."
while :; do
  read -rsp "Passphrase: " PASS; echo
  read -rsp "Confirm:    " PASS2; echo
  [ -n "$PASS" ] && [ "$PASS" = "$PASS2" ] && break
  echo "Empty or different; try again."
done

sudo mkfs.fat -F 32 -n LAPBOOT "$BOOT_PART"
printf '%s' "$PASS" | sudo cryptsetup luksFormat --type luks2 --label LAPCRYPT --batch-mode --key-file - "$SYS_PART"
printf '%s' "$PASS" | sudo cryptsetup luksFormat --type luks2 --label LAPHOME --batch-mode --key-file - "$HOME_PART"
printf '%s' "$PASS" | sudo cryptsetup open --key-file - "$SYS_PART" laptop-cryptroot
printf '%s' "$PASS" | sudo cryptsetup open --key-file - "$HOME_PART" laptop-crypthome
unset PASS PASS2

sudo mkfs.btrfs -f -L nixos-sys /dev/mapper/laptop-cryptroot
sudo mkfs.btrfs -f -L nixos-home /dev/mapper/laptop-crypthome

step "4. Subvolumes and mounting"
opts="compress=zstd,noatime"

sudo mount /dev/mapper/laptop-cryptroot /mnt
sudo btrfs subvolume create /mnt/@ /mnt/@nix
sudo umount /mnt
sudo mount -o "subvol=@,$opts" /dev/mapper/laptop-cryptroot /mnt
sudo mkdir -p /mnt/nix /mnt/home /mnt/boot
sudo mount -o "subvol=@nix,$opts" /dev/mapper/laptop-cryptroot /mnt/nix

sudo mount /dev/mapper/laptop-crypthome /mnt/home
sudo btrfs subvolume create /mnt/home/@home
sudo umount /mnt/home
sudo mount -o "subvol=@home,$opts" /dev/mapper/laptop-crypthome /mnt/home

sudo mount -o fmask=0077,dmask=0077 "$BOOT_PART" /mnt/boot
findmnt -R -l /mnt

fi

cleanup() {
  sudo umount -R /mnt 2>/dev/null || true
  sudo cryptsetup close laptop-cryptroot 2>/dev/null || true
  sudo cryptsetup close laptop-crypthome 2>/dev/null || true
}
trap cleanup EXIT

step "5. Installing NixOS"
cd "$REPO"
sudo nixos-install --root /mnt --flake .#laptop --no-root-passwd

step "6. Password for the mael user"
until sudo nixos-enter --root /mnt -c '/nix/var/nix/profiles/system/sw/bin/passwd mael'; do
  echo "Passwords do not match; try again."
done

step "7. Unmounting"
cleanup

step "Done!"
cat <<'EOF'
Reboot and remove the USB drive: NixOS boots from the internal disk.

Then, to stop entering the passphrase at every boot
(unlocking with the TPM):

  bash scripts/enroll-tpm.sh

To remove the old Pop!_OS boot entry from the BIOS:

  sudo efibootmgr                  # find the Pop!_OS entry number
  sudo efibootmgr -b <number> -B
EOF
