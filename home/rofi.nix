{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    settings = {
      terminal = "${pkgs.kitty}/bin/kitty";
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "Applications";
      display-run = "Run";
      display-window = "Windows";
      drun-display-format = "{name}";
      font = "JetBrainsMono Nerd Font 13";
      me-select-entry = "";
      me-accept-entry = "MousePrimary";
    };
  };
}
