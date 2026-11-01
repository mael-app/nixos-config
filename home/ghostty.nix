{ config, palette, ... }:

{
  xdg.configFile."ghostty/gtk.css".text = ''
    /* Ghostty uses GTK's tab widget; style it separately from the terminal
       canvas so the tab strip does not fall back to Adwaita grey. */
    window,
    tabbar,
    tabbar > revealer > box {
      background: ${palette.hex "mantle"};
      color: ${palette.hex "text"};
    }

    tabbar tab {
      background: ${palette.hex "surface0"};
      color: ${palette.hex "subtext0"};
      border-radius: 8px 8px 0 0;
      margin: 4px 2px 0;
      padding: 5px 12px;
    }

    tabbar tab:checked {
      background: ${palette.hex "base"};
      color: ${palette.hex "text"};
      box-shadow: inset 0 2px ${palette.hex "blue"};
    }

    tabbar tab:hover:not(:checked) {
      background: ${palette.hex "surface1"};
      color: ${palette.hex "text"};
    }

    tabbar button {
      color: ${palette.hex "subtext0"};
      background: transparent;
      border-radius: 6px;
    }

    tabbar button:hover {
      color: ${palette.hex "text"};
      background: ${palette.rgba "blue" "0.18"};
    }
  '';

  # The module also installs Ghostty's D-Bus activated systemd user service,
  # so new windows open in the already running instance instead of cold
  # starting GTK each time.
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

      # Catppuccin Mocha, from the same palette as the rest of the desktop.
      background = palette.hex "base";
      foreground = palette.hex "text";
      cursor-color = palette.hex "rosewater";
      selection-background = palette.hex "surface0";
      selection-foreground = palette.hex "text";
      window-titlebar-background = palette.hex "base";
      window-titlebar-foreground = palette.hex "text";
      gtk-custom-css = "${config.xdg.configHome}/ghostty/gtk.css";
      palette = [
        "0=${palette.hex "surface1"}"
        "1=${palette.hex "red"}"
        "2=${palette.hex "green"}"
        "3=${palette.hex "yellow"}"
        "4=${palette.hex "blue"}"
        "5=${palette.hex "pink"}"
        "6=${palette.hex "teal"}"
        "7=${palette.hex "subtext1"}"
        "8=${palette.hex "surface2"}"
        "9=${palette.hex "red"}"
        "10=${palette.hex "green"}"
        "11=${palette.hex "yellow"}"
        "12=${palette.hex "blue"}"
        "13=${palette.hex "pink"}"
        "14=${palette.hex "teal"}"
        "15=${palette.hex "subtext0"}"
      ];

      background-opacity = 0.92;
      window-padding-x = 10;
      window-padding-y = 8;
      window-padding-balance = true;
      mouse-hide-while-typing = true;
      confirm-close-surface = false;
      # Hyprland tiles the window; a GTK title bar would only waste a row.
      window-decoration = "none";
      # The tab bar is separate from the title bar, so it still shows above.
      window-show-tab-bar = "always";
      # Browser-style tab shortcuts on top of the ctrl+shift defaults. They
      # take ctrl+t and ctrl+w away from the shell (ctrl+w deletes a word).
      keybind = [
        "ctrl+t=new_tab"
        "ctrl+w=close_tab:this"
      ];
    };
  };
}
