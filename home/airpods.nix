{ pkgs, ... }:

let
  # LibrePods switches the AirPods to the first A2DP profile it finds in a
  # hardcoded list that puts SBC-XQ and SBC ahead of the plain a2dp-sink
  # profile. PipeWire gives that plain profile the best codec the AirPods
  # accept, which is AAC, so the list is reordered to try it first.
  librepods = pkgs.librepods.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace media/mediacontroller.cpp \
        --replace-fail '{"a2dp-sink-sbc_xq", "a2dp-sink-sbc", "a2dp-sink"}' \
                       '{"a2dp-sink", "a2dp-sink-sbc_xq", "a2dp-sink-sbc"}'
    '';
  });
in

# LibrePods talks to AirPods over Bluetooth. It pauses the MPRIS player when a
# bud leaves an ear and resumes it when the bud goes back in, and its Waybar
# tray icon switches between noise cancellation, transparency and adaptive
# mode and shows the battery levels.
{
  home.packages = [ librepods ];

  systemd.user.services.librepods = {
    Unit = {
      Description = "LibrePods AirPods tray";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "tray.target"
      ];
      Requires = [ "tray.target" ];
    };

    Service = {
      # --hide keeps the main window closed; the tray icon opens it.
      ExecStart = "${librepods}/bin/librepods --hide";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
