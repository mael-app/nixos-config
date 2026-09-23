{ lib, ... }:

# NixOS installed on an external USB SSD, booted from the laptop's
# firmware boot menu. Nothing is written to the internal disks or to the
# laptop's UEFI boot entries.
{
  imports = [ ../../modules/laptop.nix ];

  boot.loader.systemd-boot = {
    enable = true;
    # Keep the ESP small and the boot menu readable.
    configurationLimit = 10;
  };
  # Don't register a boot entry in the laptop's firmware: systemd-boot is
  # also installed to the removable fallback path (EFI/BOOT/BOOTX64.EFI),
  # so the drive boots from the firmware boot menu on any UEFI machine.
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "nixos-usb";

  home-manager.users.mael.wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    -- Laptop screen: 2560x1600. Valid scales: 1, 1.0667, 1.25, 1.3333, 1.6, 2
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
  '';

  system.stateVersion = "25.11";
}
