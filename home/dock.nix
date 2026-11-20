{
  config,
  pkgs,
  lib,
  palette,
  ...
}:

let
  discordBaseIcon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/discord.svg";
in

# Always-visible dock with pinnable apps.
{
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

  xdg = {
    dataFile."applications/discord.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Discord
      GenericName=Instant Messenger
      Comment=All-in-one voice and text chat
      Exec=Discord %U
      Icon=${discordBaseIcon}
      Categories=Network;InstantMessaging;
      MimeType=x-scheme-handler/discord;
    '';

    # Apps pinned in the dock, in order. Each entry is a .desktop file name
    # without the extension (see /run/current-system/sw/share/applications).
    # The file is read-only, so right-click > Pin in the dock no longer persists.
    cacheFile."nwg-dock-pinned".text = lib.concatLines [
      "firefox"
      "com.mitchellh.ghostty"
      "thunar"
      "spotify"
      "code"
      "com.anthropic.Claude"
      "discord"
      "signal"
      "1password"
      "mullvad-vpn"
    ];

    configFile."nwg-dock-hyprland/style.css".text = ''
      window {
        background: ${palette.rgba "base" "0.85"};
        border-radius: 14px;
        border: 2px solid ${palette.rgba "blue" "0.3"};
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
        color: ${palette.hex "text"};
      }

      button:hover {
        background: ${palette.rgba "text" "0.1"};
      }

      button:focus {
        background: ${palette.rgba "blue" "0.2"};
      }
    '';
  };
}
