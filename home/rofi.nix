{ pkgs, palette, ... }:

let
  # Same design language as waybar and the dock: a translucent pill on a
  # blurred backdrop (the blur comes from the rofi layer rule in
  # hyprland.nix) with the shared Catppuccin accents.
  theme = pkgs.writeText "rofi-catppuccin.rasi" ''
    * {
      bg:          ${palette.rgba "base" "0.92"};
      fg:          ${palette.hex "text"};
      fg-dim:      ${palette.hex "overlay1"};
      accent:      ${palette.hex "blue"};
      accent-soft: ${palette.rgba "blue" "0.3"};
      surface:     ${palette.rgba "text" "0.06"};
      on-accent:   ${palette.hex "base"};

      background-color: transparent;
      text-color: @fg;
      margin: 0;
      padding: 0;
      spacing: 0;
    }

    window {
      width: 640px;
      padding: 12px;
      border: 2px solid;
      border-color: @accent-soft;
      border-radius: 12px;
      background-color: @bg;
    }

    mainbox {
      children: [ inputbar, message, listview, mode-switcher ];
      spacing: 8px;
    }

    inputbar {
      children: [ prompt, entry ];
      spacing: 8px;
      padding: 8px 12px;
      border-radius: 8px;
      background-color: @surface;
    }

    prompt {
      text-color: @accent;
    }

    entry {
      placeholder: "Search";
      placeholder-color: @fg-dim;
    }

    message {
      padding: 8px 12px;
      border-radius: 8px;
      background-color: @surface;
    }

    listview {
      lines: 8;
      columns: 1;
      spacing: 2px;
      fixed-height: false;
      scrollbar: false;
    }

    element {
      orientation: horizontal;
      children: [ element-icon, element-text ];
      spacing: 8px;
      padding: 8px;
      border-radius: 8px;
    }

    element-icon {
      size: 24px;
      vertical-align: 0.5;
    }

    element-text {
      vertical-align: 0.5;
    }

    element selected {
      background-color: @accent;
      text-color: @on-accent;
    }

    mode-switcher {
      spacing: 4px;
    }

    button {
      padding: 6px 12px;
      border-radius: 8px;
      background-color: @surface;
      text-color: @fg;
    }

    button selected {
      background-color: @accent;
      text-color: @on-accent;
    }
  '';
in
{
  programs.rofi = {
    enable = true;
    theme = toString theme;
    settings = {
      terminal = "${pkgs.ghostty}/bin/ghostty";
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
