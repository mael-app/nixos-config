{ lib, ... }:

# NixOS installed on an external USB SSD, booted from the laptop's
# firmware boot menu. Nothing is written to the internal disks or to the
# laptop's UEFI boot entries.
{
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

  # / , /nix and /home are all subvolumes of the one LUKS container on the
  # stick, so a single mount point covers the whole filesystem.
  services.btrfs.autoScrub.fileSystems = [ "/" ];

  home-manager.users.mael.wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    -- Laptop screen: 2560x1600. Valid scales: 1, 1.0667, 1.25, 1.3333, 1.6, 2
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
  '';

  # Scale 1.25 leaves 2048x1280 logical pixels instead of the laptop's
  # 2560x1600, and wlogout margins are absolute, so the defaults would leave
  # the power menu 40 pixels tall.
  home-manager.users.mael.local.powerMenu = {
    verticalMargin = 480;
    horizontalMargin = 380;
  };

  system.stateVersion = "25.11";
}
