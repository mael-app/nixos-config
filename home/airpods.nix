{ pkgs, ... }:

# LibrePods talks to AirPods over Bluetooth. It pauses the MPRIS player when a
# bud leaves an ear and resumes it when the bud goes back in, and its Waybar
# tray icon switches between noise cancellation, transparency and adaptive
# mode and shows the battery levels.
{
  home.packages = [ pkgs.librepods ];

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
      ExecStart = "${pkgs.librepods}/bin/librepods --hide";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
