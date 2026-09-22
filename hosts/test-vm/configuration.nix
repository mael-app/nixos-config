{ config, pkgs, ... }:

{
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  networking.hostName = "nixos-test";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  users.users.mael = {
    isNormalUser = true;
    description = "Maël";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  # Allow only the non-free packages we explicitly use.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "terraform"
    ];

  # Keep the Nix CLI + flakes enabled.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Let wheel users use sudo. A password will be configured after installation.
  security.sudo.wheelNeedsPassword = true;

  system.stateVersion = "25.11";
}
