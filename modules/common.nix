{ pkgs, ... }:

# Settings shared by every machine.
{
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

  # Keep the Nix store small: dedupe identical files and drop old
  # generations every week.
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Only the non-free packages we explicitly use.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "terraform"
      "vscode"
      "discord"
      "discord-unwrapped"
      "1password"
      "1password-cli"
      "claude-code"
    ];

  security.sudo.wheelNeedsPassword = true;
}
