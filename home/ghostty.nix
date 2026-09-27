{ ... }:

{
  # The module also installs Ghostty's D-Bus activated systemd user service,
  # so new windows open in the already running instance instead of cold
  # starting GTK each time.
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      background-opacity = 0.92;
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
