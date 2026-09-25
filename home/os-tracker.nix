{ config, inputs, ... }:

# Presence daemon for the portfolio badge: it posts a heartbeat to the edge
# API every few minutes. The module and the binary come from the os-tracker
# flake, so `nix flake update os-tracker` is what upgrades it.
{
  imports = [ inputs.os-tracker.homeModules.default ];

  services.os-tracker = {
    enable = true;
    apiUrl = "https://os-tracker.mael-app.workers.dev";
    interval = 120;

    # Holds `OS_TRACKER_TOKEN=<token>`, read by systemd when the service
    # starts. The file is created by hand and never enters this repository or
    # the Nix store.
    tokenFile = "${config.home.homeDirectory}/.config/os-tracker/token.env";
  };
}
