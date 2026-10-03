{ pkgs, ... }:

# Animated wallpaper. mpvpaper plays a looping video on the background layer,
# above the still image awww draws, so stopping it uncovers that image rather
# than an empty desktop.
#
# A controller decides what the video does and settles the same state on every
# event, so the order events arrive in does not matter:
# - in the power-saver profile mpvpaper is not running at all;
# - when a fullscreen window sits on a workspace a monitor is showing, the
#   video is paused, and it resumes once no visible window is fullscreen.
#
# Events come from power-profiles-daemon over D-Bus and from Hyprland's event
# socket. Nothing polls.
let
  video = ./wallpapers/Liquid.mp4;

  controller = pkgs.writeShellApplication {
    name = "wallpaper-video";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.mpvpaper
      pkgs.power-profiles-daemon
      pkgs.hyprland
      pkgs.jq
      pkgs.socat
      pkgs.glib
    ];
    text = ''
      mpv_socket="$XDG_RUNTIME_DIR/wallpaper-video.sock"
      hypr_socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

      pid=""
      paused=""

      running() {
        [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
      }

      start_video() {
        rm -f "$mpv_socket"
        mpvpaper -o "loop no-audio hwdec=auto-safe panscan=1.0 input-ipc-server=$mpv_socket" \
          '*' ${video} &
        pid=$!
        paused=no
        # The IPC socket appears a moment after mpv starts.
        for _ in $(seq 50); do
          [ -S "$mpv_socket" ] && return
          sleep 0.1
        done
      }

      stop_video() {
        if running; then
          kill "$pid"
          wait "$pid" || true
        fi
        pid=""
        paused=""
      }

      set_pause() {
        [ "$paused" = "$1" ] && return
        local value=false
        [ "$1" = yes ] && value=true
        echo "{\"command\": [\"set_property\", \"pause\", $value]}" |
          socat - "UNIX-CONNECT:$mpv_socket" >/dev/null 2>&1 || true
        paused=$1
      }

      # True when a window in real fullscreen, not merely maximised, is on a
      # workspace one of the monitors is showing. Hyprland's fullscreen field
      # is a bit mask in which 2 is fullscreen and 1 is maximised.
      fullscreen_visible() {
        local shown
        shown="$(hyprctl -j monitors | jq -c '[.[].activeWorkspace.id]')"
        hyprctl -j clients | jq -e --argjson shown "$shown" \
          'any(.[]; (.fullscreen / 2 | floor) % 2 == 1 and (.workspace.id as $id | $shown | index($id)) != null)' \
          >/dev/null
      }

      settle() {
        if [ "$(powerprofilesctl get)" = power-saver ]; then
          stop_video
          return
        fi
        running || start_video
        if fullscreen_visible; then
          set_pause yes
        else
          set_pause no
        fi
      }

      {
        gdbus monitor --system --dest org.freedesktop.UPower.PowerProfiles &
        socat -U - "UNIX-CONNECT:$hypr_socket"
      } | {
        # The video state lives in this side of the pipeline, so the cleanup
        # does too.
        trap 'stop_video' EXIT
        settle
        while read -r event; do
          case "$event" in
            *ActiveProfile* | fullscreen\>\>* | workspace* | focusedmon* | \
              openwindow\>\>* | closewindow\>\>* | movewindow* | monitor*)
              settle
              ;;
          esac
        done
      }
    '';
  };
in
{
  systemd.user.services.wallpaper-video = {
    Unit = {
      Description = "Animated wallpaper";
      PartOf = [ "graphical-session.target" ];
      # Started after the still image is up, so the video lands on top of it.
      After = [
        "graphical-session.target"
        "awww-wallpaper.service"
      ];
    };
    Service = {
      ExecStart = "${controller}/bin/wallpaper-video";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
