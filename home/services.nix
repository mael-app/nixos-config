{ lib, ... }:

# Long-running pieces of the session that Home Manager has a module for.
{
  # Lock after 5 min idle, screen off after 10 min
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        }
      ];
    };
  };

  # Clipboard history (SUPER + SHIFT + V)
  services.cliphist.enable = true;

  # Notification daemon. The module owns the unit, config.json and style.css.
  services.swaync = {
    enable = true;
    settings = lib.importJSON ./swaync/config.json;
    style = ./swaync/style.css;
  };

  # Keep the clipboard alive after the copying window closes.
  services.wl-clip-persist = {
    enable = true;
    clipboardType = "regular";
  };

  # Battery and AC notifications.
  services.poweralertd.enable = true;

  # NetworkManager tray icon. preferStatusNotifierItems makes the module
  # pass --indicator, which is what the Waybar tray expects.
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;

  # Authentication prompts for apps asking for root (polkit)
  services.hyprpolkitagent.enable = true;

  # Volume / brightness on-screen popups
  services.swayosd.enable = true;

  # Tray applets
  services.blueman-applet.enable = true;
}
