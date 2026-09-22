{ config, pkgs, ... }:

{
  # QEMU/KVM VM: legacy BIOS + GRUB.
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  networking.hostName = "nixos-test";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  # TTY / login keyboard.
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

  # Nix CLI + flakes globally enabled.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Only the non-free packages we explicitly use.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "terraform"
    ];

  security.sudo.wheelNeedsPassword = true;

  system.stateVersion = "25.11";
}
