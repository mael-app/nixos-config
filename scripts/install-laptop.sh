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
die() { printf '\033[1;31mErreur : %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "lance ce script avec ton utilisateur, pas en root"
[ -f "$REPO/flake.nix" ] || die "flake.nix introuvable dans $REPO"
command -v nixos-install >/dev/null || die "lance ce script depuis le NixOS de la clé USB"

if [ "$INSTALL_ONLY" = true ]; then
  findmnt /mnt/boot >/dev/null && findmnt /mnt/home >/dev/null \
    || die "le disque n'est pas monté sur /mnt (relance sans --install-only)"
else

step "1. Vérification du disque cible ($TARGET)"
[ -b "$TARGET" ] || die "$TARGET n'existe pas"

# Never touch the disk the running system boots from (the USB drive).
# lsblk lists the whole tree of TARGET, including dm/LUKS devices, so a
# running root sitting anywhere under it is caught.
running_src="$(findmnt -no SOURCE / || true)"
if [ -n "$running_src" ] && lsblk -npo NAME "$TARGET" | grep -qxF "$running_src"; then
  die "$TARGET porte le système en cours d'exécution"
fi

# Never touch the Windows disk.
if lsblk -no FSTYPE "$TARGET" | grep -qi bitlocker; then
  die "$TARGET contient un volume BitLocker (Windows), abandon"
fi

lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$TARGET"
printf '\n\033[1;31mTOUT LE CONTENU DE %s (Pop!_OS) VA ÊTRE EFFACÉ.\033[0m\n' "$TARGET"
echo "Système : $SYS_SIZE   /home : le reste du disque"
read -rp "Tape EFFACER pour continuer : " answer
[ "$answer" = "EFFACER" ] || die "annulé"

step "2. Partitionnement"
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
  [ -b "$p" ] || die "partition $p introuvable"
done

step "3. Chiffrement et formatage"
echo "Une seule phrase de passe pour les deux volumes (système et /home)."
echo "systemd la met en cache : tu ne la tapes qu'une fois au démarrage."
while :; do
  read -rsp "Phrase de passe : " PASS; echo
  read -rsp "Confirme        : " PASS2; echo
  [ -n "$PASS" ] && [ "$PASS" = "$PASS2" ] && break
  echo "Vide ou différente, recommence."
done

sudo mkfs.fat -F 32 -n LAPBOOT "$BOOT_PART"
printf '%s' "$PASS" | sudo cryptsetup luksFormat --type luks2 --label LAPCRYPT --batch-mode --key-file - "$SYS_PART"
printf '%s' "$PASS" | sudo cryptsetup luksFormat --type luks2 --label LAPHOME --batch-mode --key-file - "$HOME_PART"
printf '%s' "$PASS" | sudo cryptsetup open --key-file - "$SYS_PART" cryptroot
printf '%s' "$PASS" | sudo cryptsetup open --key-file - "$HOME_PART" crypthome
unset PASS PASS2

sudo mkfs.btrfs -f -L nixos-sys /dev/mapper/cryptroot
sudo mkfs.btrfs -f -L nixos-home /dev/mapper/crypthome

step "4. Sous-volumes et montage"
opts="compress=zstd,noatime"

sudo mount /dev/mapper/cryptroot /mnt
sudo btrfs subvolume create /mnt/@ /mnt/@nix
sudo umount /mnt
sudo mount -o "subvol=@,$opts" /dev/mapper/cryptroot /mnt
sudo mkdir -p /mnt/nix /mnt/home /mnt/boot
sudo mount -o "subvol=@nix,$opts" /dev/mapper/cryptroot /mnt/nix

sudo mount /dev/mapper/crypthome /mnt/home
sudo btrfs subvolume create /mnt/home/@home
sudo umount /mnt/home
sudo mount -o "subvol=@home,$opts" /dev/mapper/crypthome /mnt/home

sudo mount -o fmask=0077,dmask=0077 "$BOOT_PART" /mnt/boot
findmnt -R -l /mnt

fi

step "5. Installation de NixOS"
cd "$REPO"
sudo nixos-install --root /mnt --flake .#laptop --no-root-passwd

step "6. Mot de passe de l'utilisateur mael"
sudo nixos-enter --root /mnt -c '/nix/var/nix/profiles/system/sw/bin/passwd mael'

step "7. Démontage"
sudo umount -R /mnt
sudo cryptsetup close cryptroot
sudo cryptsetup close crypthome

step "Terminé !"
cat <<'EOF'
Redémarre, retire la clé USB : NixOS démarre depuis le disque interne.

Ensuite, pour ne plus taper la phrase de passe à chaque démarrage
(déverrouillage par la puce TPM) :

  bash scripts/enroll-tpm.sh

Pour supprimer l'ancienne entrée de démarrage Pop!_OS du BIOS :

  sudo efibootmgr                  # repère le numéro de « Pop!_OS »
  sudo efibootmgr -b <numéro> -B
EOF
