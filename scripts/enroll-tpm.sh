#!/usr/bin/env bash
# Enroll the laptop's TPM 2.0 so both LUKS volumes unlock automatically at
# boot. Run it ON THE INSTALLED LAPTOP SYSTEM, after the first boot.
#
# The passphrase stays enrolled as a fallback: if the TPM refuses (BIOS
# update, Secure Boot change, disk moved to another machine), the usual
# prompt comes back.
set -euo pipefail

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31mErreur : %s\033[0m\n' "$*" >&2; exit 1; }

[ -e /dev/tpm0 ] || [ -e /dev/tpmrm0 ] || die "aucune puce TPM détectée"

for label in LAPCRYPT LAPHOME; do
  dev="/dev/disk/by-label/$label"
  [ -e "$dev" ] || die "$dev introuvable (ce script est pour la machine 'laptop')"

  step "Enrôlement du TPM pour $label"
  echo "Tape ta phrase de passe LUKS quand elle est demandée."
  # PCR 7 = Secure Boot state, PCR 0 = firmware. Changing either falls
  # back to the passphrase, which stays enrolled.
  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "$dev"
done

step "Terminé"
cat <<'MSG'
Redémarre pour vérifier : le système doit démarrer sans demander la phrase.

Si elle est encore demandée, le TPM a refusé (état du Secure Boot ou du
BIOS différent de l'enrôlement) : relance ce script pour ré-enrôler.

Pour retirer le déverrouillage automatique :
  sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-label/LAPCRYPT
  sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-label/LAPHOME
MSG
