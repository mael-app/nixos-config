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

  programs.kitty = {
    enable = true;
    settings = {
      font_size = 11;
    };
  };

  home.packages = with pkgs; [
    starship
  ];

  home.sessionVariables = {
    GDK_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "1";
  };

  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "network" "pulseaudio" "clock" ];
        "hyprland/workspaces" = {
          format = "{name}";
        };
        "hyprland/window" = {
          max-length = 60;
        };
        network = {
          format-wifi = "{essid} {signalStrength}%";
          format-ethernet = "Ethernet";
          format-disconnected = "Offline";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "Muted";
          format-icons = [ "" "" "" ];
          on-click = "pavucontrol";
        };
        clock = {
          format = "{:%a %d/%m  %H:%M}";
          tooltip-format = "{:%A %d %B %Y}";
        };
      };

      dock = {
        layer = "top";
        position = "bottom";
        height = 44;
        exclusive = false;
        modules-center = [ "wlr/taskbar" ];
        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 26;
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
          on-click-right = "context";
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      window#waybar {
        background: rgba(30, 30, 30, 0.92);
        color: #eeeeee;
      }

      #workspaces button,
      #clock,
      #network,
      #pulseaudio,
      #window {
        padding: 0 10px;
      }

      #workspaces button.active {
        color: #8ec07c;
      }

      #taskbar button {
        padding: 0 8px;
        margin: 4px 2px;
      }

      #taskbar button.active {
        background: rgba(142, 192, 124, 0.25);
      }
    '';
  };

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
