# Replace this placeholder with the hardware configuration generated
# specifically for this VM.
#
# Existing installed VM:
#   cp /etc/nixos/hardware-configuration.nix hosts/test-vm/
#
# Live ISO:
#   nixos-generate-config --root /mnt
#   then copy /mnt/etc/nixos/hardware-configuration.nix here.

{ ... }:

throw ''
  Replace hosts/test-vm/hardware-configuration.nix with the hardware
  configuration generated for this VM.
''
