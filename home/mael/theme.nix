{ config, pkgs, ... }:

# Dark theme, icons, cursor, and the Qt platform theme that follows GTK.
{
  # Dark GTK theme, icons and cursor
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };
}
