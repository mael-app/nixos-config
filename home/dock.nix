{
  config,
  pkgs,
  lib,
  ...
}:

# Always-visible dock with pinnable apps.
{
  # Always-visible dock with pinnable apps.
  systemd.user.services.nwg-dock = {
    Unit = {
      Description = "Application dock";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.nwg-dock-hyprland}/bin/nwg-dock-hyprland"
        "-x"
        "-i 48"
        "-mb 8"
        "-c '${config.programs.rofi.finalPackage}/bin/rofi -show drun'"
      ];
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Apps pinned in the dock, in order. Each entry is a .desktop file name
  # without the extension (see /run/current-system/sw/share/applications).
  # The file is read-only, so right-click > Pin in the dock no longer persists.
  xdg.cacheFile."nwg-dock-pinned".text = lib.concatLines [
    "firefox"
    "kitty"
    "thunar"
    "spotify"
    "code"
    "discord"
    "1password"
    "mullvad-vpn"
  ];

  xdg.configFile."nwg-dock-hyprland/style.css".text = ''
    window {
      background: rgba(26, 27, 38, 0.85);
      border-radius: 14px;
      border: 2px solid rgba(137, 180, 250, 0.3);
    }

    #box {
      padding: 6px;
    }

    button {
      background: transparent;
      border: none;
      border-radius: 10px;
      padding: 4px;
      margin: 0 2px;
      color: #cdd6f4;
    }

    button:hover {
      background: rgba(205, 214, 244, 0.1);
    }

    button:focus {
      background: rgba(137, 180, 250, 0.2);
    }
  '';
}
