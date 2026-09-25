{
  config,
  pkgs,
  wallpaper,
  ...
}:

# Login screen. ReGreet is a GTK greeter for greetd, so it can show the same
# wallpaper as the session instead of tuigreet's bare text console. The NixOS
# module runs it inside cage, a Wayland compositor that hosts a single
# fullscreen window, and writes /etc/greetd/regreet.toml and regreet.css.
{
  services.displayManager.regreet = {
    enable = true;

    settings = {
      # `fit` is left alone: the default already covers the screen, and the
      # accepted values are not documented in the package.
      background.path = wallpaper;

      appearance.greeting_msg = "Welcome back";

      GTK.application_prefer_dark_theme = true;

      # ReGreet has a clock widget; tuigreet showed the time with --time.
      widget.clock = {
        format = "%A %d %B  %H:%M";
        resolution = "1s";
        # ReGreet derives a locale from LANG and then fails to parse the
        # "en-US" it produces, falling back with a warning. Naming it in the
        # form it accepts keeps the day and month names localised.
        locale = "en_US";
      };
    };

    # The same theme, icons, cursor and font as the session, so the login
    # screen and the desktop look like one machine.
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
    font = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
      size = 16;
    };

    # A bad rule here is skipped with a warning rather than breaking the
    # greeter, but keep it to things that cannot move the layout.
    extraCss = ''
      /* The clock and the greeting sit straight on the wallpaper, so they
         need their own contrast to survive a light part of the image. */
      label {
        text-shadow: 0 1px 4px rgba(0, 0, 0, 0.6);
      }

      entry,
      button {
        border-radius: 8px;
      }
    '';
  };

  # ReGreet lists the sessions it finds under XDG_DATA_DIRS, falling back to
  # /usr/share/wayland-sessions, which does not exist here. greetd is a system
  # service and does not get environment.sessionVariables, so without this the
  # session list would be empty and there would be nothing to log in to.
  systemd.services.greetd.environment.XDG_DATA_DIRS =
    "${config.services.displayManager.sessionData.desktops}/share";
}
