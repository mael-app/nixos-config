{ ... }:

# Mael's Home Manager configuration, one file per concern. Anything that only
# this user runs belongs here; the system, its services and other users are
# configured under ../../modules.
{
  imports = [
    ./dock.nix
    ./gh.nix
    ./git.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./kitty.nix
    ./os-tracker.nix
    ./packages.nix
    ./power-menu.nix
    ./rofi.nix
    ./services.nix
    ./session.nix
    ./shell.nix
    ./ssh.nix
    ./sounds.nix
    ./theme.nix
    ./waybar.nix
    ./xdg.nix
  ];

  home.username = "mael";
  home.homeDirectory = "/home/mael";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    GDK_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "1";
  };
}
