#!/usr/bin/env bash
# Enroll the laptop's TPM 2.0 so both LUKS volumes unlock automatically at
# boot. Run it ON THE INSTALLED LAPTOP SYSTEM, after the first boot.
#
# The passphrase stays enrolled as a fallback: if the TPM refuses (BIOS
# update, Secure Boot change, disk moved to another machine), the usual
# prompt comes back.
set -euo pipefail

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }

[ -e /dev/tpm0 ] || [ -e /dev/tpmrm0 ] || die "no TPM chip detected"

for label in LAPCRYPT LAPHOME; do
  dev="/dev/disk/by-label/$label"
  [ -e "$dev" ] || die "$dev not found (this script is for the 'laptop' machine)"

  step "Enrolling the TPM for $label"
  echo "Enter your LUKS passphrase when prompted."
  # PCR 7 = Secure Boot state, PCR 0 = firmware. Changing either falls
  # back to the passphrase, which stays enrolled.
  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "$dev"
done

step "Done"
cat <<'MSG'
Reboot to verify: the system should boot without requesting the passphrase.

If it is still requested, the TPM refused (Secure Boot or BIOS state differs
from enrollment): run this script again to re-enroll.

To remove automatic unlocking:
  sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-label/LAPCRYPT
  sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-label/LAPHOME
MSG
