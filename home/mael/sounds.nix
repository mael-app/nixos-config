{ pkgs, ... }:

# Subtle audio feedback for power and login events.
{
  # Subtle sounds when the laptop is plugged in or unplugged.
  systemd.user.services.power-connection-sound = {
    Unit = {
      Description = "Play a sound when AC power changes";
      After = [
        "pipewire.service"
        "pipewire-pulse.service"
      ];
    };
    Service = {
      ExecStart = pkgs.writeShellScript "power-connection-sound" ''
        ac_device="$(${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep '/line_power_' | ${pkgs.coreutils}/bin/head -n1)"
        [ -n "$ac_device" ] || exit 0

        get_state() {
          ${pkgs.upower}/bin/upower -i "$ac_device" | ${pkgs.gawk}/bin/awk '/online:/ { print $2; exit }'
        }

        play_sound() {
          ${pkgs.pipewire}/bin/pw-play "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/$1.oga"
        }

        previous_state="$(get_state)"
        [ -n "$previous_state" ] || exit 0

        ${pkgs.upower}/bin/upower --monitor | while read -r _; do
          current_state="$(get_state)"
          if [ "$previous_state" = "no" ] && [ "$current_state" = "yes" ]; then
            play_sound power-plug
          elif [ "$previous_state" = "yes" ] && [ "$current_state" = "no" ]; then
            play_sound power-unplug
          fi
          previous_state="$current_state"
        done
      '';
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.session-login-sound = {
    Unit = {
      Description = "Play a sound when the graphical session starts";
      After = [
        "pipewire.service"
        "pipewire-pulse.service"
      ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.pipewire}/bin/pw-play ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/service-login.oga";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
