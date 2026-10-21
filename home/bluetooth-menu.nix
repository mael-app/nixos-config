{
  lib,
  pkgs,
  ...
}:

# The Bluetooth menu opened from the waybar Bluetooth icon. It lists only the
# devices already paired with this machine, so connecting the AirPods never
# starts a discovery and never pulls in the crowd of nearby devices that makes
# blueman-manager slow to open. Pairing a brand new device stays possible, but
# it is an explicit entry that opens the full manager on demand.
#
# One script answers waybar's status query, opens the menu and toggles the
# adapter, so the icon, its menu and its right click share a single source of
# truth. It never scans: `bluetoothctl devices Paired` reads the adapter's
# cache, which is instant whatever else is in the room.
let
  menu = pkgs.writeShellApplication {
    name = "bluetooth-menu";
    runtimeInputs = [
      pkgs.blueman
      pkgs.bluez
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.hyprland
      pkgs.jq
      pkgs.libnotify
      pkgs.rofi
    ];
    text = ''
      adapter="$(bluetoothctl show 2>/dev/null || true)"
      if [ -n "$adapter" ] && grep -q '^[[:space:]]*Powered: yes' <<<"$adapter"; then
        is_powered=yes
      else
        is_powered=no
      fi

      # "Device XX:XX:XX:XX:XX:XX Name with spaces"
      macs_of() {
        bluetoothctl devices "$1" | sed 's/^Device \([0-9A-Fa-f:]*\) .*/\1/'
      }

      names_of() {
        bluetoothctl devices "$1" | sed 's/^Device [0-9A-Fa-f:]* //'
      }

      alias_of() {
        bluetoothctl info "$1" | sed -n 's/^[[:space:]]*Alias: //p'
      }

      case "''${1:-menu}" in
        status)
          if [ -z "$adapter" ]; then
            jq -cn '{text:"󰂲", class:"disabled", tooltip:"No Bluetooth adapter"}'
          elif [ "$is_powered" = no ]; then
            jq -cn '{text:"󰂲", class:"off", tooltip:"Bluetooth off"}'
          else
            mapfile -t connected < <(names_of Connected)
            count="''${#connected[@]}"
            if [ "$count" -eq 0 ]; then
              jq -cn '{text:"󰂯", class:"on", tooltip:"Bluetooth on"}'
            else
              text="󰂱  ''${connected[0]}"
              if [ "$count" -gt 1 ]; then
                text="$text +$(( count - 1 ))"
              fi
              tooltip="$(printf '%s\n' "''${connected[@]}")"
              jq -cn --arg text "$text" --arg tooltip "$tooltip" \
                '{text:$text, class:"connected", tooltip:$tooltip}'
            fi
          fi
          ;;

        toggle)
          bluetoothctl power toggle >/dev/null 2>&1 || true
          ;;

        menu)
          if [ -z "$adapter" ]; then
            notify-send -a Bluetooth "Bluetooth" "No Bluetooth adapter found"
            exit 0
          fi

          labels=()
          keys=()
          selected=0

          # Paired devices are read from the adapter cache, which lists them
          # even while the adapter is off, so the menu is never empty and a
          # selection can turn the adapter on and connect in one go.
          mapfile -t connected_macs < <(macs_of Connected)
          mapfile -t paired_macs < <(macs_of Paired)
          mapfile -t paired_names < <(names_of Paired)

          for i in "''${!paired_macs[@]}"; do
            mac="''${paired_macs[$i]}"
            name="''${paired_names[$i]}"
            if printf '%s\n' "''${connected_macs[@]}" | grep -qx "$mac"; then
              # Preselect the first connected device, like the macOS menu.
              if [ "$selected" -eq 0 ]; then
                selected="''${#labels[@]}"
              fi
              labels+=("󰂱  $name  󰄬")
            else
              labels+=("󰂯  $name")
            fi
            keys+=("connect:$mac")
          done

          labels+=("󰂱  Pair a new device…")
          keys+=("pair")

          if [ "$is_powered" = yes ]; then
            labels+=("󰂲  Turn off Bluetooth")
            keys+=("power:off")
          else
            labels+=("󰂯  Turn on Bluetooth")
            keys+=("power:on")
          fi

          # Rofi ignores -xoffset under Wayland, so the position goes through
          # the theme and the y-offset counts from the bottom of the bar. The
          # menu opens under the pointer, which is on the Bluetooth icon.
          width=320
          cursor="$(hyprctl cursorpos)"
          monitor="$(hyprctl -j monitors | jq -r '.[] | select(.focused) | "\(.x) \(.width) \(.scale)"')"
          read -r mon_x mon_w mon_scale <<<"$monitor"
          mon_w="$(awk -v w="$mon_w" -v s="$mon_scale" 'BEGIN { printf "%d", w / s }')"
          x=$(( ''${cursor%%,*} - mon_x - width / 2 ))
          if [ "$x" -gt "$(( mon_w - width - 10 ))" ]; then
            x=$(( mon_w - width - 10 ))
          fi
          if [ "$x" -lt 10 ]; then
            x=10
          fi

          choice="$(
            printf '%s\n' "''${labels[@]}" |
              rofi -dmenu -no-custom -hover-select -format i \
                -selected-row "$selected" \
                -theme-str "window { location: northwest; anchor: northwest; x-offset: ''${x}px; y-offset: 6px; width: ''${width}px; } inputbar { enabled: false; } listview { lines: 8; scrollbar: false; }"
          )" || exit 0

          key="''${keys[$choice]}"
          case "$key" in
            connect:*)
              mac="''${key#connect:}"
              name="$(alias_of "$mac")"
              if grep -q '^[[:space:]]*Connected: yes' <<<"$(bluetoothctl info "$mac")"; then
                bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
                notify-send -a Bluetooth "Bluetooth" "Disconnected from $name"
              else
                # A device chosen while the adapter was off powers it on first.
                bluetoothctl power on >/dev/null 2>&1 || true
                if bluetoothctl connect "$mac" >/dev/null 2>&1; then
                  notify-send -a Bluetooth "Bluetooth" "Connected to $name"
                else
                  notify-send -a Bluetooth "Bluetooth" "Could not connect to $name"
                fi
              fi
              ;;
            power:on)
              bluetoothctl power on >/dev/null 2>&1 || true
              ;;
            power:off)
              bluetoothctl power off >/dev/null 2>&1 || true
              ;;
            pair)
              blueman-manager &
              ;;
          esac
          ;;
      esac
    '';
  };
in
{
  options.local.bluetoothMenu.command = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    description = ''
      The command that opens the Bluetooth device menu. It takes an optional
      argument: "status" prints the waybar status JSON and "toggle" flips the
      adapter power.
    '';
  };

  config.local.bluetoothMenu.command = lib.getExe menu;
}
