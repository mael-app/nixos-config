{
  config,
  pkgs,
  wallpaper,
  ...
}:

# Session daemons that ship no Home Manager module, so the units are written
# here rather than autostarted from the Hyprland configuration.
{
  # Windows-style window switcher: ALT + Tab opens a grid with one tile per
  # window and keeps it open while ALT is held, so Tab walks the list instead
  # of toggling between the last two windows.
  #
  # hyprshell only auto-discovers config.ron, so the service below points at
  # this file explicitly. JSON is valid JSON5, which lets Nix build the config
  # rather than us hand-writing RON.
  xdg.configFile."hyprshell/config.json5".text = builtins.toJSON {
    version = 4;
    windows = {
      switch = {
        modifier = "alt";
        # A GDK key name, so capitalised: "tab" is rejected at runtime.
        key = "Tab";
        # Walk through windows, not workspaces.
        switch_workspaces = false;
        # No filter, so every window on every workspace gets a tile.
        filter_by = [ ];
      };
    };
  };

  # Wallpaper daemon. It was started from hyprland.start with a `sleep 1`
  # before the first image so the socket had time to appear; systemd expresses
  # that ordering properly.
  systemd.user.services.awww = {
    Unit = {
      Description = "Wallpaper daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # The image lives in this repository and ends up in the Nix store.
  #
  # Pulled in by awww.service, not by graphical-session.target. A oneshot unit
  # wanted by a target makes the target wait for it to finish, which closed an
  # ordering cycle: the target waited on this unit, this unit waits on
  # awww.service, and awww.service waits on the target. systemd broke the
  # cycle by dropping awww.service, so after a reboot neither the daemon nor
  # the wallpaper came up.
  systemd.user.services.awww-wallpaper = {
    Unit = {
      Description = "Set the desktop wallpaper";
      PartOf = [ "awww.service" ];
      Requires = [ "awww.service" ];
      After = [ "awww.service" ];
      # The retry below needs room: the default of five attempts in ten
      # seconds can expire before the daemon has bound its socket.
      StartLimitBurst = 10;
      StartLimitIntervalSec = 60;
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.awww}/bin/awww img ${wallpaper} --transition-type fade";
      # awww-daemon binds its socket just after systemd considers it started,
      # so the first attempt can still lose the race. Retrying is cheaper than
      # guessing at a sleep, and the unit settles on the first success.
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "awww.service" ];
  };

  # The daemon registers its own ALT + Tab binds with Hyprland and re-registers
  # them on every Hyprland config reload, which is why the Lua configuration
  # further down deliberately leaves ALT + Tab unbound.
  systemd.user.services.hyprshell = {
    Unit = {
      Description = "Window switcher for Hyprland";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprshell}/bin/hyprshell run --config-file ${config.xdg.configHome}/hyprshell/config.json5";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
