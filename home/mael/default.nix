{ pkgs, lib, ... }:

{
  home.username = "mael";
  home.homeDirectory = "/home/mael";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  home.packages = with pkgs; [
    starship
  ];

  # Hyprland 0.55+ uses Lua configuration.
  #
  # Explicitly set configType because home.stateVersion is kept at 25.11
  # and Home Manager would otherwise default this configuration to hyprlang.
  wayland.windowManager.hyprland = {
    enable = true;

    # Hyprland is already installed by the NixOS module above.
    package = null;

    configType = "lua";

    # We use the current Hyprland Lua API directly. This avoids generating
    # the old hyprland.conf format.
    extraConfig = ''
      -- Mael's Hyprland configuration
      -- Hyprland 0.55+ / Lua

      local mainMod = "SUPER"

      hl.config({
        input = {
          kb_layout = "fr",
          kb_variant = "",
          follow_mouse = 1,
          sensitivity = 0,
        },

        general = {
          gaps_in = 5,
          gaps_out = 10,
          border_size = 2,
          layout = "dwindle",
        },

        decoration = {
          rounding = 8,
        },

        misc = {
          disable_hyprland_logo = true,
          disable_splash_rendering = true,
        },

        xwayland = {
          enabled = true,
        },
      })

      -- Applications / services
      hl.exec_cmd("waybar")
      hl.exec_cmd("dunst")
      hl.exec_cmd("nm-applet --indicator")

      -- Terminal
      hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))

      -- Application launcher
      hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))

      -- File manager
      hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))

      -- Window management
      hl.bind(mainMod .. " + C", hl.dsp.window.close())
      hl.bind(mainMod .. " + V", hl.dsp.window.float())
      hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

      -- Exit Hyprland
      hl.bind(mainMod .. " + M", hl.dsp.exit())

      -- Workspaces
      for i = 1, 5 do
        hl.bind(
          mainMod .. " + " .. tostring(i),
          hl.dsp.focus({ workspace = i })
        )

        hl.bind(
          mainMod .. " + SHIFT + " .. tostring(i),
          hl.dsp.window.move({ workspace = i })
        )
      end
    '';

    # Home Manager's systemd integration is enabled by default.
    # Keep it enabled because we launch a normal Hyprland session.
    systemd.enable = true;
  };
}
