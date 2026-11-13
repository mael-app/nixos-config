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

# LibrePods is available for manually requested AirPods controls, but it must
# not start its own connection loop alongside Blueman and PipeWire. The latter
# are responsible for connecting paired Bluetooth audio devices.
{
  home.packages = [ librepods ];
}
