#!/usr/bin/env bash
# Install the `usb` host onto the SSK Portable SSD, from Pop!_OS.
# Automates docs/install-usb.md. ERASES THE USB SSD.
#
# Usage (from the repo root, as your user, not root):
#   bash scripts/install-usb.sh                 # full install (steps 1-7)
#   bash scripts/install-usb.sh --install-only  # resume at step 5, when the
#                                               # drive is already mounted on /mnt
set -euo pipefail

INSTALL_ONLY=false
[ "${1:-}" = "--install-only" ] && INSTALL_ONLY=true

MODEL_PATTERN="SSK Portable SSD"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "run this script as your user, not as root (it uses sudo itself)"
[ -f "$REPO/flake.nix" ] || die "flake.nix not found in $REPO"
command -v nix >/dev/null || die "nix is not installed"

if [ "$INSTALL_ONLY" = true ]; then
  findmnt /mnt/boot >/dev/null && findmnt /mnt/nix >/dev/null \
    || die "the drive is not mounted on /mnt (run the script without --install-only)"
else

step "1. Finding the USB drive ($MODEL_PATTERN)"
mapfile -t matches < <(lsblk -dnpo NAME,TRAN,MODEL | awk -v m="$MODEL_PATTERN" '$2 == "usb" && index($0, m) { print $1 }')
[ "${#matches[@]}" -eq 1 ] || die "exactly one USB drive matching \"$MODEL_PATTERN\" must be connected (found: ${#matches[@]})"
DISK="${matches[0]}"
case "$DISK" in
  /dev/nvme*) die "$DISK is an internal disk; aborting" ;;
esac

lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,TRAN,MODEL "$DISK"
printf '\n\033[1;31mALL CONTENTS OF %s WILL BE ERASED.\033[0m\n' "$DISK"
read -rp "Type ERASE to continue: " answer
[ "$answer" = "ERASE" ] || die "cancelled"

step "Installing missing tools (btrfs-progs)"
sudo apt-get install -y btrfs-progs parted cryptsetup dosfstools

step "2. Partitioning"
for part in "$DISK"?*; do
  [ -b "$part" ] && sudo umount "$part" 2>/dev/null || true
done
sudo wipefs -a "$DISK"
sudo parted -s "$DISK" -- \
  mklabel gpt \
  mkpart NIXBOOT fat32 1MiB 1GiB \
  set 1 esp on \
  mkpart NIXCRYPT 1GiB 100%
sudo partprobe "$DISK"
sudo udevadm settle
BOOT_PART="${DISK}1"
CRYPT_PART="${DISK}2"
[ -b "$BOOT_PART" ] && [ -b "$CRYPT_PART" ] || die "partitions not found after partitioning"

# Pop!_OS may auto-mount the new partitions
sudo umount "$BOOT_PART" "$CRYPT_PART" 2>/dev/null || true

step "3. Formatting and encryption"
sudo mkfs.fat -F 32 -n NIXBOOT "$BOOT_PART"
echo
echo "Choose the encryption passphrase (requested at every boot)."
echo "Type YES in uppercase when cryptsetup asks for it."
sudo cryptsetup luksFormat --type luks2 --label NIXCRYPT "$CRYPT_PART"
echo
echo "Re-enter the passphrase to open the volume:"
sudo cryptsetup open "$CRYPT_PART" cryptroot
sudo mkfs.btrfs -f -L nixos /dev/mapper/cryptroot

step "4. Subvolumes and mounting"
sudo mount /dev/mapper/cryptroot /mnt
sudo btrfs subvolume create /mnt/@ /mnt/@home /mnt/@nix
sudo umount /mnt

opts="compress=zstd,noatime"
sudo mount -o "subvol=@,$opts" /dev/mapper/cryptroot /mnt
sudo mkdir -p /mnt/home /mnt/nix /mnt/boot
sudo mount -o "subvol=@home,$opts" /dev/mapper/cryptroot /mnt/home
sudo mount -o "subvol=@nix,$opts" /dev/mapper/cryptroot /mnt/nix
sudo mount -o fmask=0077,dmask=0077 "$BOOT_PART" /mnt/boot
findmnt -R -l /mnt

fi

step "5. Installing NixOS (several GB to download)"
echo "In China: make sure Mullvad is connected, or GitHub may fail."
read -rp "Use Chinese Nix cache mirrors (Mullvad disconnected)? [y/N] " mirrors
extra=""
if [[ "$mirrors" =~ ^[oOyY]$ ]]; then
  # priority=10 beats cache.nixos.org (40), so the mirrors are tried first
  extra='--option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10 https://mirrors.ustc.edu.cn/nix-channels/store?priority=20 https://cache.nixos.org"'
fi

cd "$REPO"
nix shell .#nixosConfigurations.nixos-usb.pkgs.nixos-install-tools --command bash -c "
  set -e
  sudo env \"PATH=\$PATH\" nixos-install --root /mnt --flake .#nixos-usb --no-root-passwd $extra

  echo
  echo '==> 6. Password for the mael user (login, sudo, unlocking)'
  # Full path: /run/wrappers (where passwd usually lives) doesn't exist in the chroot
  sudo env \"PATH=\$PATH\" nixos-enter --root /mnt -c '/nix/var/nix/profiles/system/sw/bin/passwd mael'
"

step "7. Unmounting"
sudo umount -R /mnt
sudo cryptsetup close cryptroot

step "Done!"
cat <<'EOF'
To boot from the drive:
  1. BIOS: disable Secure Boot (note your BitLocker recovery key first).
  2. Boot menu (F12 / F8 / Esc...): choose the SSK drive.
  3. LUKS passphrase, then log in.
Next: docs/install-usb.md, section 9.
EOF
