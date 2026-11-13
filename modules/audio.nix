_:

# PipeWire replacing PulseAudio and JACK.
{
  # Lets PipeWire ask for the realtime priority it needs to avoid xruns.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Do not expose speaker monitor ports as microphone choices in apps.
    wireplumber.extraConfig."10-disable-audio-monitor-ports" = {
      "wireplumber.settings" = {
        "node.features.audio.monitor-ports" = false;
      };
    };

    # Prefer the high-quality playback profile for Bluetooth headsets. Without
    # this, WirePlumber may restore the hands-free or off profile selected by a
    # previous connection. AAC is built into PipeWire's BlueZ SPA plugin and is
    # the best codec supported by AirPods.
    wireplumber.extraConfig."20-bluetooth-audio" = {
      "monitor.bluez.properties" = {
        "bluez5.auto-connect" = [ "a2dp_sink" ];
        "bluez5.codecs" = [
          "aac"
          "sbc_xq"
          "sbc"
        ];
        "bluez5.enable-sbc-xq" = true;
      };

      # Keep an explicitly selected hands-free profile from being restored as
      # the default when the device reconnects.
      "monitor.bluez.rules" = [
        {
          matches = [
            {
              "device.name" = "~bluez_card.*";
            }
          ];
          actions = {
            update-props = {
              "device.profile" = "a2dp-sink";
            };
          };
        }
      ];
    };
  };
}
