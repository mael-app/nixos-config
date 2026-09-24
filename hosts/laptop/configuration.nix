{ lib, username, ... }:

# NixOS on the laptop's internal 1 TB NVMe (replaces Pop!_OS).
# Windows stays untouched on the second NVMe.
{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  # Internal install: register NixOS in the firmware so it boots by default.
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-laptop";

  # / and /nix are subvolumes of the same LUKS container, so scrubbing both
  # would read laptop-cryptroot twice. /home is a separate container.
  services.btrfs.autoScrub.fileSystems = [
    "/"
    "/home"
  ];

  home-manager.users.${username}.wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    -- Laptop screen: 2560x1600. Use integer scaling for crisp dock icons.
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
  '';

  system.stateVersion = "25.11";
}
