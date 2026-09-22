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
      font_size = 12;
      background_opacity = "0.92";
      confirm_os_window_close = 0;
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

  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Adwaita";
      display-drun = "Applications";
      display-run = "Run";
      display-window = "Windows";
      drun-display-format = "{name}";
      font = "JetBrainsMono Nerd Font 11";
      me-select-entry = "";
      me-accept-entry = "MousePrimary";
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 10;
        frame_color = "#89b4fa";
        font = "JetBrainsMono Nerd Font 10";
        corner_radius = 10;
        icon_position = "left";
        max_icon_size = 64;
      };
      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 5;
      };
      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 10;
      };
      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#f38ba8";
        timeout = 0;
      };
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "custom/launcher" "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "network" "pulseaudio" "clock" ];
        "custom/launcher" = {
          format = "Applications";
          on-click = "rofi -show drun";
          tooltip = false;
        };
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
        font-weight: 600;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(26, 27, 38, 0.85);
        color: #cdd6f4;
        border-bottom: 2px solid rgba(137, 180, 250, 0.3);
      }

      #workspaces button,
      #custom-launcher,
      #clock,
      #network,
      #pulseaudio,
      #window {
        padding: 0 12px;
        margin: 0 2px;
        background: transparent;
        color: #cdd6f4;
      }

      #custom-launcher {
        color: #a6e3a1;
        font-weight: bold;
        font-size: 15px;
        padding: 0 15px;
        background: rgba(166, 227, 161, 0.1);
        border-radius: 8px;
        margin: 4px 8px;
      }

      #custom-launcher:hover {
        background: rgba(166, 227, 161, 0.2);
      }

      #workspaces {
        background: transparent;
      }

      #workspaces button {
        color: #7f849c;
        border-radius: 8px;
        margin: 4px 2px;
        transition: all 0.3s ease;
      }

      #workspaces button.active {
        color: #89b4fa;
        background: rgba(137, 180, 250, 0.2);
      }

      #workspaces button:hover {
        background: rgba(137, 180, 250, 0.1);
        color: #89b4fa;
      }

      #window {
        color: #cba6f7;
        font-style: italic;
      }

      #network {
        color: #89dceb;
      }

      #pulseaudio {
        color: #f9e2af;
      }

      #clock {
        color: #fab387;
        font-weight: bold;
        padding: 0 15px;
        background: rgba(250, 179, 135, 0.1);
        border-radius: 8px;
        margin: 4px 8px 4px 4px;
      }

      #taskbar {
        background: transparent;
      }

      #taskbar button {
        padding: 0 10px;
        margin: 6px 4px;
        background: rgba(205, 214, 244, 0.05);
        border-radius: 8px;
        color: #cdd6f4;
        transition: all 0.3s ease;
      }

      #taskbar button:hover {
        background: rgba(205, 214, 244, 0.1);
      }

      #taskbar button.active {
        background: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
      }

      tooltip {
        background: rgba(26, 27, 38, 0.95);
        border: 2px solid rgba(137, 180, 250, 0.3);
        border-radius: 8px;
        color: #cdd6f4;
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
          "col.active_border" = "rgba(8ec07cee) rgba(b8bb26ee) 45deg",
          "col.inactive_border" = "rgba(595959aa)",
        },

        decoration = {
          rounding = 10,
          active_opacity = 1.0,
          inactive_opacity = 0.95,
          fullscreen_opacity = 1.0,

          drop_shadow = true,
          shadow_range = 8,
          shadow_render_power = 2,
          "col.shadow" = "rgba(1a1a1aee)",

          blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
          },
        },

        animations = {
          enabled = true,
          bezier = {
            "myBezier, 0.05, 0.9, 0.1, 1.05",
            "linear, 0.0, 0.0, 1.0, 1.0",
            "wind, 0.05, 0.9, 0.1, 1.05",
            "winIn, 0.1, 1.1, 0.1, 1.0",
            "winOut, 0.3, -0.3, 0, 1",
          },
          animation = {
            "windows, 1, 6, wind, slide",
            "windowsIn, 1, 6, winIn, slide",
            "windowsOut, 1, 5, winOut, slide",
            "windowsMove, 1, 5, wind, slide",
            "border, 1, 10, default",
            "fade, 1, 10, default",
            "workspaces, 1, 5, wind",
          },
        },

        dwindle = {
          pseudotile = true,
          preserve_split = true,
        },

        misc = {
          disable_hyprland_logo = true,
          disable_splash_rendering = true,
          mouse_move_enables_dpms = true,
          key_press_enables_dpms = true,
          vrr = 0,
        },

        xwayland = {
          enabled = true,
        },
      })

      -- Applications / services
      hl.exec_cmd("nm-applet --indicator")
      hl.exec_cmd("swww-daemon")

      -- Set a random wallpaper on startup (you can change the path)
      -- hl.exec_cmd("swww img ~/Pictures/wallpaper.jpg")
      -- Or use a solid color:
      -- hl.exec_cmd("swww img -c 1e1e2e")

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
      hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

      -- Screenshots
      hl.bind(", Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
      hl.bind("SHIFT, Print", hl.dsp.exec_cmd("grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"))

      -- Lock screen
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("swaylock -f -c 000000"))

      -- Exit Hyprland
      hl.bind(mainMod .. " + M", hl.dsp.exit())

      -- Window focus
      hl.bind(mainMod .. " + left", hl.dsp.focus("l"))
      hl.bind(mainMod .. " + right", hl.dsp.focus("r"))
      hl.bind(mainMod .. " + up", hl.dsp.focus("u"))
      hl.bind(mainMod .. " + down", hl.dsp.focus("d"))

      -- Move windows
      hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move("l"))
      hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move("r"))
      hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move("u"))
      hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move("d"))

      -- Resize windows
      hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -50, y = 0 }))
      hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0 }))
      hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -50 }))
      hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 50 }))

      -- Workspaces
      for i = 1, 10 do
        hl.bind(
          mainMod .. " + " .. tostring(i % 10),
          hl.dsp.focus({ workspace = i })
        )

        hl.bind(
          mainMod .. " + SHIFT + " .. tostring(i % 10),
          hl.dsp.window.move({ workspace = i })
        )
      end

      -- Mouse bindings
      hl.bind("mouse:" .. mainMod .. " + button:272", hl.dsp.window.move())
      hl.bind("mouse:" .. mainMod .. " + button:273", hl.dsp.window.resize())
    '';

    # Home Manager's systemd integration is enabled by default.
    # Keep it enabled because we launch a normal Hyprland session.
    systemd.enable = true;
  };
}
