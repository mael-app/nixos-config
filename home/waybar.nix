{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;
        spacing = 4;
        modules-left = [
          "custom/launcher"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "idle_inhibitor"
          "pulseaudio"
          "backlight"
          "custom/kbd-backlight"
          "network"
          "bluetooth"
          "battery"
          "cpu"
          "memory"
          "custom/notification"
          "custom/power"
        ];

        "custom/launcher" = {
          format = "󱄅";
          on-click = "rofi -show drun";
          tooltip = false;
        };
        "custom/notification" = {
          tooltip-format = "Notifications";
          format = "󰂚";
          return-type = "json";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          format-icons = {
            notification = "󰂚";
            none = "󰂜";
            dnd-notification = "󰂛";
            dnd-none = "󰪓";
          };
        };
        "hyprland/workspaces" = {
          format = "{name}";
          on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
          on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
        };
        "hyprland/window" = {
          max-length = 40;
          separate-outputs = true;
        };
        clock = {
          format = "󰥔  {:%H:%M}";
          format-alt = "󰃭  {:%A %d %B %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            weeks-pos = "right";
            format = {
              today = "<span color='#fab387'><b><u>{}</u></b></span>";
            };
          };
        };
        tray = {
          icon-size = 16;
          spacing = 8;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰾪";
          };
          tooltip-format-activated = "Idle inhibition enabled";
          tooltip-format-deactivated = "Idle inhibition disabled";
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            headphone = "󰋋";
          };
          scroll-step = 5;
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        backlight = {
          format = "{icon}  {percent}%";
          format-icons = [
            "󰃞"
            "󰃟"
            "󰃠"
          ];
          on-scroll-up = "brightnessctl set 5%+";
          on-scroll-down = "brightnessctl set 5%-";
        };
        "custom/kbd-backlight" = {
          format = "󰌌  {}";
          exec = "brightnessctl -m -d kbd_backlight | cut -d, -f4";
          interval = 2;
          on-scroll-up = "brightnessctl -d kbd_backlight set 5%+";
          on-scroll-down = "brightnessctl -d kbd_backlight set 5%-";
          tooltip = false;
        };
        network = {
          format-wifi = "󰖩  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Offline";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          on-click = "nm-connection-editor";
        };
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-connected = "󰂱  {device_alias}";
          tooltip-format = "{controller_alias}";
          on-click = "blueman-manager";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-icons = [
            "󰁺"
            "󰁼"
            "󰁾"
            "󰂀"
            "󰁹"
          ];
          on-click = pkgs.writeShellScript "show-battery-time" ''
            battery="$(${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep '/battery_' | ${pkgs.coreutils}/bin/head -n1)"
            [ -n "$battery" ] || exit 0

            info="$(${pkgs.upower}/bin/upower -i "$battery")"
            state="$(printf '%s\n' "$info" | ${pkgs.gawk}/bin/awk '/state:/ { print $2; exit }')"
            case "$state" in
              charging)
                label="Time until fully charged"
                estimate="$(printf '%s\n' "$info" | ${pkgs.gawk}/bin/awk '/time to full:/ { $1=$2=""; sub(/^ +/, ""); print; exit }')"
                ;;
              discharging)
                label="Time until battery empty"
                estimate="$(printf '%s\n' "$info" | ${pkgs.gawk}/bin/awk '/time to empty:/ { $1=$2=""; sub(/^ +/, ""); print; exit }')"
                ;;
              *)
                label="Battery"
                estimate="non disponible"
                ;;
            esac

            [ -n "$estimate" ] || estimate="non disponible"
            ${pkgs.libnotify}/bin/notify-send -a "Battery" -t 4000 "$label" "$estimate"
          '';
        };
        cpu = {
          format = "󰍛  {usage}%";
          interval = 5;
          on-click = "kitty --class btop -e btop";
        };
        memory = {
          format = "󰘚  {percentage}%";
          interval = 5;
          on-click = "kitty --class btop -e btop";
        };
        "custom/power" = {
          format = "⏻";
          on-click = config.local.powerMenu.command;
          tooltip = false;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 15px;
        font-weight: 600;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(26, 27, 38, 0.80);
        color: #cdd6f4;
        border: 2px solid rgba(137, 180, 250, 0.3);
        border-radius: 12px;
      }

      #custom-launcher,
      #custom-notification,
      #workspaces,
      #window,
      #clock,
      #tray,
      #idle_inhibitor,
      #pulseaudio,
      #backlight,
      #network,
      #bluetooth,
      #battery,
      #cpu,
      #memory,
      #custom-power {
        padding: 0 10px;
        margin: 4px 0;
        border-radius: 8px;
        background: rgba(205, 214, 244, 0.06);
      }

      #custom-launcher {
        color: #89b4fa;
        font-size: 18px;
        margin-left: 4px;
        padding: 0 12px 0 10px;
      }

      #custom-notification {
        color: #f9e2af;
      }

      #workspaces {
        padding: 0 2px;
      }

      #workspaces button {
        color: #7f849c;
        padding: 0 6px;
        border-radius: 6px;
      }

      #workspaces button.active {
        color: #1e1e2e;
        background: #89b4fa;
      }

      #workspaces button:hover {
        background: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
      }

      #window {
        color: #cba6f7;
      }

      window#waybar.empty #window {
        background: transparent;
      }

      #clock {
        color: #fab387;
      }

      #pulseaudio {
        color: #f9e2af;
      }

      #pulseaudio.muted {
        color: #7f849c;
      }

      #backlight {
        color: #f5c2e7;
      }

      #custom-kbd-backlight {
        color: #cba6f7;
      }

      #network {
        color: #89dceb;
      }

      #network.disconnected {
        color: #f38ba8;
      }

      #bluetooth {
        color: #74c7ec;
      }

      #battery {
        color: #a6e3a1;
      }

      #battery.warning {
        color: #f9e2af;
      }

      #battery.critical {
        color: #f38ba8;
      }

      #cpu {
        color: #94e2d5;
      }

      #memory {
        color: #b4befe;
      }

      #idle_inhibitor.activated {
        color: #fab387;
      }

      #custom-power {
        color: #f38ba8;
        margin-right: 4px;
      }

      tooltip {
        background: rgba(26, 27, 38, 0.95);
        border: 2px solid rgba(137, 180, 250, 0.3);
        border-radius: 8px;
        color: #cdd6f4;
      }
    '';
  };
}
