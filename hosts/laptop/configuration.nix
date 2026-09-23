{ lib, ... }:

# NixOS on the laptop's internal 1 TB NVMe (replaces Pop!_OS).
# Windows stays untouched on the second NVMe.
{
  imports = [ ../../modules/laptop.nix ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  # Internal install: register NixOS in the firmware so it boots by default.
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-laptop";

  home-manager.users.mael.wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    -- Laptop screen: 2560x1600. Valid scales: 1, 1.0667, 1.25, 1.3333, 1.6, 2
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
  '';

  system.stateVersion = "25.11";
}
