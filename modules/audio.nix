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
  };
}
