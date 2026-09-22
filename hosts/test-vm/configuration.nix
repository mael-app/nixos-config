{ config, pkgs, ... }:

{
  # QEMU/KVM VM: legacy BIOS + GRUB.
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  networking.hostName = "nixos-test";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  # Login/TTY keyboard.
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  users.users.mael = {
    isNormalUser = true;
    description = "Maël";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "terraform"
    ];

  security.sudo.wheelNeedsPassword = true;

  system.stateVersion = "25.11";
}
