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
      -- Reference: https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

      local mainMod = "SUPER"

      -- Monitor: force scale 1 (the default "auto" can upscale everything,
      -- especially in a VM) and use the highest resolution available.
      hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })

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
          col = {
            active_border = { colors = { "rgba(89b4faee)", "rgba(a6e3a1ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
          },
        },

        decoration = {
          rounding = 10,
          rounding_power = 2,
          active_opacity = 1.0,
          inactive_opacity = 0.95,
          fullscreen_opacity = 1.0,

          shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
            color = 0xee1a1a1a,
          },

          blur = {
            enabled = true,
            size = 6,
            passes = 3,
            vibrancy = 0.1696,
            ignore_opacity = true,
            xray = false,
          },
        },

        dwindle = {
          preserve_split = true,
        },

        misc = {
          force_default_wallpaper = 0,
          disable_hyprland_logo = true,
          disable_splash_rendering = true,
          mouse_move_enables_dpms = true,
          key_press_enables_dpms = true,
        },

        xwayland = {
          enabled = true,
        },
      })

      -- Animations
      hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
      hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
      hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
      hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })
      hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

      hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
      hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
      hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
      hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "slide" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
      hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
      hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })

      -- Autostart (runs once at session start, not on every reload)
      hl.on("hyprland.start", function()
        hl.exec_cmd("nm-applet --indicator")
        hl.exec_cmd("awww-daemon")
        -- Set a wallpaper once awww-daemon is up, e.g.:
        -- hl.exec_cmd("sleep 1 && awww img ~/Pictures/wallpaper.jpg")
      end)

      -- Terminal
      hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))

      -- Application launcher
      hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))

      -- File manager
      hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))

      -- Window management
      hl.bind(mainMod .. " + C", hl.dsp.window.close())
      hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
      hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
      hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

      -- Screenshots
      hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd('grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png'))

      -- Lock screen
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("swaylock -f -c 000000"))

      -- Exit Hyprland
      hl.bind(mainMod .. " + M", hl.dsp.exit())

      -- Window focus
      hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

      -- Move windows
      hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
      hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
      hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
      hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

      -- Resize windows
      hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
      hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
      hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
      hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

      -- Workspaces (10 maps to key 0)
      for i = 1, 10 do
        local key = i % 10
        hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      -- Scroll through existing workspaces
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

      -- Move/resize windows with mainMod + LMB/RMB and dragging
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Media keys
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
    '';

    # Home Manager's systemd integration is enabled by default.
    # Keep it enabled because we launch a normal Hyprland session.
    systemd.enable = true;
  };
}
