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

# Bound to PCR 7 alone, the TPM only checks that Secure Boot is on with the
# same keys. With Secure Boot off, any image booted on this machine would get
# the key, so refuse to enroll until it is on.
# The EFI variable is read directly: bootctl needs root to read /boot and
# exits non-zero without it, which pipefail turns into a false "disabled".
# Its last byte is 1 when Secure Boot is on.
sb=/sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c
[ "$(od -An -t u1 "$sb" 2>/dev/null | awk '{print $NF}')" = 1 ] \
  || die "Secure Boot is disabled: enable it in the firmware first"

for label in LAPCRYPT LAPHOME; do
  dev="/dev/disk/by-label/$label"
  [ -e "$dev" ] || die "$dev not found (this script is for the 'laptop' machine)"

  step "Enrolling the TPM for $label"
  echo "Enter your LUKS passphrase when prompted."
  # PCR 7 = Secure Boot state and keys. PCR 11 is left out: it holds the
  # hash of the UKI itself, which lanzaboote rebuilds on every generation,
  # so binding to it broke unlocking after each rebuild. Lanzaboote's
  # signature check is what vouches for the UKI instead. A change in PCR 7
  # falls back to the passphrase, which stays enrolled. --wipe-slot replaces
  # a previous TPM enrollment instead of stacking a second one.
  sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 "$dev"
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
