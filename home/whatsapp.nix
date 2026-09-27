{ pkgs, ... }:

let
  # Karere's own desktop entry and GTK application id. Reusing the name makes
  # the entry below replace the packaged one, and lets the dock match the
  # running window to it.
  appId = "io.github.tobagin.karere";
in
{
  # WhatsApp has no official Linux client; Karere wraps WhatsApp Web in GTK4.
  home.packages = [ pkgs.karere ];

  # Shown as WhatsApp with the WhatsApp logo from the Papirus icon theme, so
  # it is found under that name in rofi and recognised in the dock.
  xdg.desktopEntries.${appId} = {
    name = "WhatsApp";
    genericName = "WhatsApp Client";
    comment = "WhatsApp Web client for the Linux desktop";
    icon = "whatsapp";
    exec = "karere %U";
    terminal = false;
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    mimeType = [ "x-scheme-handler/whatsapp" ];
    settings = {
      Keywords = "whatsapp;karere;chat;messaging;";
      StartupWMClass = appId;
    };
  };
}
