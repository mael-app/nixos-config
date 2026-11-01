{
  config,
  pkgs,
  lib,
  palette,
  ...
}:

let
  discordBadgeIcon = "${config.xdg.dataHome}/icons/discord-badge.svg";
  discordBaseIcon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/discord.svg";

  updateDiscordBadge = pkgs.writeShellApplication {
    name = "update-discord-badge";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.swaynotificationcenter
      pkgs.systemd
    ];
    text = ''
      icon="${discordBadgeIcon}"
      mkdir -p "$(dirname "$icon")"

      write_icon() {
        count="$1"
        tmp="$(mktemp ''${icon}.XXXXXX)"
        {
          cat <<'SVG'
      <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
        <image href="file://${discordBaseIcon}" width="64" height="64"/>
      SVG
          if [ "$count" -gt 0 ]; then
            label="$count"
            if [ "$count" -gt 99 ]; then label="99+"; fi
            font_size=12
            if [ "$label" = "99+" ]; then font_size=9; fi
            cat <<SVG
        <circle cx="52" cy="12" r="12" fill="#ed4245" stroke="#1e1e2e" stroke-width="3"/>
        <text x="52" y="16" text-anchor="middle" fill="#ffffff" font-family="sans-serif" font-size="''${font_size}px" font-weight="700">$label</text>
      SVG
          fi
          echo '</svg>'
        } > "$tmp"
        mv "$tmp" "$icon"
      }

      last=-1
      while IFS= read -r event; do
        count="$(printf '%s\n' "$event" | jq -r '.text // "0"')"
        case "$count" in
          *[!0-9]*|) count=0 ;;
        esac
        if [ "$count" != "$last" ]; then
          write_icon "$count"
          last="$count"
          ${pkgs.systemd}/bin/systemctl --user try-restart nwg-dock.service || true
        fi
      done < <(${pkgs.swaynotificationcenter}/bin/swaync-client --subscribe-waybar)
    '';
  };
in

# Always-visible dock with pinnable apps.
{
  systemd.user.services.nwg-dock = {
    Unit = {
      Description = "Application dock";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "discord-notification-badge.service"
      ];
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

  systemd.user.services.discord-notification-badge = {
    Unit = {
      Description = "Discord notification badge for the dock";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "swaync.service"
      ];
      Before = [ "nwg-dock.service" ];
    };
    Service = {
      ExecStart = "${updateDiscordBadge}/bin/update-discord-badge";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Home Manager's desktop-entry helper still passes the removed `extraConfig`
  # option to newer nixpkgs. Write this small override directly instead.
  xdg.dataFile."applications/discord.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Discord
    GenericName=Instant Messenger
    Comment=All-in-one voice and text chat
    Exec=Discord %U
    Icon=${discordBadgeIcon}
    Categories=Network;InstantMessaging;
    MimeType=x-scheme-handler/discord;
  '';

  # Apps pinned in the dock, in order. Each entry is a .desktop file name
  # without the extension (see /run/current-system/sw/share/applications).
  # The file is read-only, so right-click > Pin in the dock no longer persists.
  xdg.cacheFile."nwg-dock-pinned".text = lib.concatLines [
    "firefox"
    "com.mitchellh.ghostty"
    "thunar"
    "spotify"
    "code"
    "discord"
    "signal"
    "1password"
    "mullvad-vpn"
  ];

  xdg.configFile."nwg-dock-hyprland/style.css".text = ''
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
}
