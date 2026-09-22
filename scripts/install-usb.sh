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
die() { printf '\033[1;31mErreur : %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "lance ce script avec ton utilisateur, pas en root (il utilise sudo lui-même)"
[ -f "$REPO/flake.nix" ] || die "flake.nix introuvable dans $REPO"
command -v nix >/dev/null || die "nix n'est pas installé"

if [ "$INSTALL_ONLY" = true ]; then
  findmnt /mnt/boot >/dev/null && findmnt /mnt/nix >/dev/null \
    || die "la clé n'est pas montée sur /mnt (lance le script sans --install-only)"
else

step "1. Recherche de la clé USB ($MODEL_PATTERN)"
mapfile -t matches < <(lsblk -dnpo NAME,TRAN,MODEL | awk -v m="$MODEL_PATTERN" '$2 == "usb" && index($0, m) { print $1 }')
[ "${#matches[@]}" -eq 1 ] || die "il faut exactement une clé « $MODEL_PATTERN » branchée en USB (trouvé : ${#matches[@]})"
DISK="${matches[0]}"
case "$DISK" in
  /dev/nvme*) die "$DISK est un disque interne, abandon" ;;
esac

lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,TRAN,MODEL "$DISK"
printf '\n\033[1;31mTOUT LE CONTENU DE %s VA ÊTRE EFFACÉ.\033[0m\n' "$DISK"
read -rp "Tape EFFACER pour continuer : " answer
[ "$answer" = "EFFACER" ] || die "annulé"

step "Installation des outils manquants (btrfs-progs)"
sudo apt-get install -y btrfs-progs parted cryptsetup dosfstools

step "2. Partitionnement"
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
[ -b "$BOOT_PART" ] && [ -b "$CRYPT_PART" ] || die "partitions introuvables après partitionnement"

# Pop!_OS may auto-mount the new partitions
sudo umount "$BOOT_PART" "$CRYPT_PART" 2>/dev/null || true

step "3. Formatage et chiffrement"
sudo mkfs.fat -F 32 -n NIXBOOT "$BOOT_PART"
echo
echo "Choisis la phrase de passe du chiffrement (demandée à chaque démarrage)."
echo "Tape YES en majuscules quand cryptsetup le demande."
sudo cryptsetup luksFormat --type luks2 --label NIXCRYPT "$CRYPT_PART"
echo
echo "Retape la phrase de passe pour ouvrir le volume :"
sudo cryptsetup open "$CRYPT_PART" cryptroot
sudo mkfs.btrfs -f -L nixos /dev/mapper/cryptroot

step "4. Sous-volumes et montage"
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

step "5. Installation de NixOS (plusieurs Go à télécharger)"
echo "En Chine : vérifie que Mullvad est connecté, sinon GitHub risque d'échouer."
read -rp "Utiliser aussi les miroirs chinois du cache Nix (USTC) ? [o/N] " mirrors
extra=""
if [[ "$mirrors" =~ ^[oOyY]$ ]]; then
  extra='--option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org"'
fi

cd "$REPO"
nix shell .#nixosConfigurations.usb.pkgs.nixos-install-tools --command bash -c "
  set -e
  sudo env \"PATH=\$PATH\" nixos-install --root /mnt --flake .#usb --no-root-passwd $extra

  echo
  echo '==> 6. Mot de passe de l utilisateur mael (connexion, sudo, déverrouillage)'
  sudo env \"PATH=\$PATH\" nixos-enter --root /mnt -c 'passwd mael'
"

step "7. Démontage"
sudo umount -R /mnt
sudo cryptsetup close cryptroot

step "Terminé !"
cat <<'EOF'
Pour démarrer sur la clé :
  1. BIOS : désactive le Secure Boot (note ta clé BitLocker avant).
  2. Menu de démarrage (F12 / F8 / Échap...) : choisis la clé SSK.
  3. Phrase de passe LUKS, puis connexion.
Suite : docs/install-usb.md, section 9.
EOF
