{
  config,
  lib,
  pkgs,
  ...
}:

# Area screen recording (SUPER + SHIFT + R), following the same pattern as
# the bluetooth menu: one script with a subcommand per caller, so the
# Hyprland bind and the waybar indicator share a single definition.
let
  cfg = config.local.screenRecord;
in
{
  options.local.screenRecord = {
    command = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "The command that toggles an area screen recording.";
    };
  };

  config = {
    local.screenRecord.command =
      let
        script = pkgs.writeShellApplication {
          name = "screen-record";
          runtimeInputs = with pkgs; [
            wf-recorder
            slurp
            libnotify
            hyprland
            coreutils
            procps
            libva-utils
            gnugrep
          ];
          text = ''
            state="''${XDG_RUNTIME_DIR:?}/screen-recording.start"
            dir="$HOME/Videos/Recordings"

            if [ "''${1:-toggle}" = toggle ]; then
              if pgrep -x wf-recorder > /dev/null; then
                # SIGINT, so wf-recorder finalizes the container instead of
                # leaving a corrupt file behind.
                pkill -INT -x wf-recorder
                rm -f "$state"
                notify-send -a "Screen recording" -t 3000 \
                  "Recording stopped" "Saved to $dir"
              else
                mkdir -p "$dir"
                geometry="$(slurp)" || exit 0
                date +%s > "$state"
                file="$dir/recording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"

                # Encode on the GPU when the session exposes a VA-API
                # encoder. x264 on the CPU at 60 fps and 2560x1600 takes
                # several cores and stutters whatever is being recorded;
                # the Iris Xe has a dedicated H.264 encoder that leaves the
                # CPU alone. vainfo lists the encode entrypoints, so it
                # doubles as the probe: the QEMU test VM has no VA-API
                # driver, and there the recording falls back to the CPU
                # codec instead of failing. grep reads its whole input, so
                # vainfo cannot die to a SIGPIPE and flip the result under
                # pipefail.
                codec=()
                if vainfo 2>/dev/null | grep VAEntrypointEncSlice > /dev/null; then
                  codec=(--codec h264_vaapi --device /dev/dri/renderD128)
                fi

                wf-recorder --framerate 60 --geometry "$geometry" \
                  "''${codec[@]}" --file "$file" &
              fi
              # Refresh the waybar indicator now instead of at the next poll.
              pkill -RTMIN+8 -x waybar || true
            else
              # waybar status: print nothing while idle so the module hides.
              pgrep -x wf-recorder > /dev/null || exit 0
              start="$(cat "$state" 2>/dev/null || date +%s)"
              elapsed=$(( $(date +%s) - start ))
              printf '{"text": "󰑋  %02d:%02d", "class": "recording", "tooltip": "Recording — SUPER + SHIFT + R to stop"}\n' \
                "$(( elapsed / 60 ))" "$(( elapsed % 60 ))"
            fi
          '';
        };
      in
      "${script}/bin/screen-record";
  };
}
