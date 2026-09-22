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
      font_size = 10;
      background_opacity = "0.92";
      confirm_os_window_close = 0;
    };
  };

  home.packages = with pkgs; [
    starship
    btop
    noto-fonts
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
      icon-theme = "Papirus-Dark";
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

  # Dark GTK theme, icons and cursor
  gtk = {
    enable = true;
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
      size = 11;
    };
  };

  home.pointerCursor = {
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

  # Lock after 5 min idle, screen off after 10 min
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof swaylock || swaylock -f --screenshots --clock --indicator --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color 89b4fa --key-hl-color a6e3a1 --inside-color 1e1e2e88 --text-color cdd6f4";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        }
      ];
    };
  };

  # Clipboard history (SUPER + SHIFT + V)
  services.cliphist.enable = true;

  # Authentication prompts for apps asking for root (polkit)
  services.hyprpolkitagent.enable = true;

  # Volume / brightness on-screen popups
  services.swayosd.enable = true;

  # Tray applets
  services.blueman-applet.enable = true;

  # Apps pinned in the dock, in order. Each entry is a .desktop file name
  # without the extension (see /run/current-system/sw/share/applications).
  # The file is read-only, so right-click > Pin in the dock no longer persists.
  xdg.cacheFile."nwg-dock-pinned".text = lib.concatLines [
    "firefox"
    "kitty"
    "thunar"
    "spotify"
    "code"
    "discord"
    "1password"
    "mullvad-vpn"
  ];

  xdg.configFile."nwg-dock-hyprland/style.css".text = ''
    window {
      background: rgba(26, 27, 38, 0.85);
      border-radius: 14px;
      border: 2px solid rgba(137, 180, 250, 0.3);
    }

    #box {
      padding: 6px;
    }

    button {
      background: transparent;
      border: none;
      border-radius: 10px;
      padding: 4px;
      margin: 0 2px;
      color: #cdd6f4;
    }

    button:hover {
      background: rgba(205, 214, 244, 0.1);
    }

    button:focus {
      background: rgba(137, 180, 250, 0.2);
    }
  '';

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;
        spacing = 4;
        modules-left = [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "idle_inhibitor"
          "pulseaudio"
          "backlight"
          "network"
          "bluetooth"
          "battery"
          "cpu"
          "memory"
          "custom/power"
        ];

        "custom/launcher" = {
          format = "󱄅";
          on-click = "rofi -show drun";
          tooltip = false;
        };
        "hyprland/workspaces" = {
          format = "{name}";
          on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
          on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
        };
        "hyprland/window" = {
          max-length = 40;
          separate-outputs = true;
        };
        clock = {
          format = "󰥔  {:%H:%M}";
          format-alt = "󰃭  {:%A %d %B %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            weeks-pos = "right";
            format = {
              today = "<span color='#fab387'><b><u>{}</u></b></span>";
            };
          };
        };
        tray = {
          icon-size = 16;
          spacing = 8;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰾪";
          };
          tooltip-format-activated = "Mise en veille désactivée";
          tooltip-format-deactivated = "Mise en veille activée";
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  muet";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
            headphone = "󰋋";
          };
          scroll-step = 5;
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        backlight = {
          format = "{icon}  {percent}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
          on-scroll-up = "brightnessctl set 5%+";
          on-scroll-down = "brightnessctl set 5%-";
        };
        network = {
          format-wifi = "󰖩  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Hors ligne";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          on-click = "nm-connection-editor";
        };
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-connected = "󰂱  {device_alias}";
          tooltip-format = "{controller_alias}";
          on-click = "blueman-manager";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
        };
        cpu = {
          format = "󰍛  {usage}%";
          interval = 5;
          on-click = "kitty --class btop -e btop";
        };
        memory = {
          format = "󰘚  {percentage}%";
          interval = 5;
          on-click = "kitty --class btop -e btop";
        };
        "custom/power" = {
          format = "⏻";
          on-click = "wlogout";
          tooltip = false;
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
        background: rgba(26, 27, 38, 0.80);
        color: #cdd6f4;
        border: 2px solid rgba(137, 180, 250, 0.3);
        border-radius: 12px;
      }

      #custom-launcher,
      #workspaces,
      #window,
      #clock,
      #tray,
      #idle_inhibitor,
      #pulseaudio,
      #backlight,
      #network,
      #bluetooth,
      #battery,
      #cpu,
      #memory,
      #custom-power {
        padding: 0 10px;
        margin: 4px 0;
        border-radius: 8px;
        background: rgba(205, 214, 244, 0.06);
      }

      #custom-launcher {
        color: #89b4fa;
        font-size: 18px;
        margin-left: 4px;
        padding: 0 12px 0 10px;
      }

      #workspaces {
        padding: 0 2px;
      }

      #workspaces button {
        color: #7f849c;
        padding: 0 6px;
        border-radius: 6px;
      }

      #workspaces button.active {
        color: #1e1e2e;
        background: #89b4fa;
      }

      #workspaces button:hover {
        background: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
      }

      #window {
        color: #cba6f7;
      }

      window#waybar.empty #window {
        background: transparent;
      }

      #clock {
        color: #fab387;
      }

      #pulseaudio {
        color: #f9e2af;
      }

      #pulseaudio.muted {
        color: #7f849c;
      }

      #backlight {
        color: #f5c2e7;
      }

      #network {
        color: #89dceb;
      }

      #network.disconnected {
        color: #f38ba8;
      }

      #bluetooth {
        color: #74c7ec;
      }

      #battery {
        color: #a6e3a1;
      }

      #battery.warning {
        color: #f9e2af;
      }

      #battery.critical {
        color: #f38ba8;
      }

      #cpu {
        color: #94e2d5;
      }

      #memory {
        color: #b4befe;
      }

      #idle_inhibitor.activated {
        color: #fab387;
      }

      #custom-power {
        color: #f38ba8;
        margin-right: 4px;
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

      -- Monitor: "preferred" follows the display's native mode (in the VM,
      -- virtio-gpu reports the virt-manager window size). Fixed scale because
      -- "auto" can upscale everything.
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.0 })

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
          -- Magnetic snapping of floating windows to screen edges and each other
          snap = {
            enabled = true,
            respect_gaps = true,
          },
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

        -- Virtual GPUs (QEMU/virtio) often draw an invisible or offset
        -- hardware cursor; software cursors are reliable there.
        cursor = {
          no_hardware_cursors = 1,
        },
      })

      -- Floating windows by default (Pop!_OS / macOS style).
      -- SUPER + T toggles auto-tiling, SUPER + V tiles/floats a single window.
      local floatRule = hl.window_rule({
        name = "float-by-default",
        match = { class = ".*" },
        float = true,
        size = { "(monitor_w*0.6)", "(monitor_h*0.65)" },
        center = true,
      })
      local autoTile = false

      -- System monitor opened from waybar: btop needs at least 80x24 cells
      hl.window_rule({
        name = "btop-size",
        match = { class = "^btop$" },
        float = true,
        size = { "(monitor_w*0.8)", "(monitor_h*0.8)" },
        center = true,
      })

      -- Usable area of a monitor (global logical coordinates), minus bars/dock
      local gap = 10
      local function usable_area(mon)
        local r = mon.reserved
        return {
          x = mon.x + r.left + gap,
          y = mon.y + r.top + gap,
          w = mon.width / mon.scale - r.left - r.right - 2 * gap,
          h = mon.height / mon.scale - r.top - r.bottom - 2 * gap,
        }
      end

      -- Snap the active window to a zone of its monitor
      local function snap(zone)
        local win = hl.get_active_window()
        if not win or not win.monitor then return end
        if not win.floating then
          hl.dispatch(hl.dsp.window.float({ action = "set" }))
        end

        local a = usable_area(win.monitor)
        local g = gap / 2
        local hw, hh = a.w / 2, a.h / 2
        local zones = {
          left         = { a.x,          a.y,          hw - g,   a.h },
          right        = { a.x + hw + g, a.y,          hw - g,   a.h },
          maximize     = { a.x,          a.y,          a.w,      a.h },
          center       = { a.x + a.w * 0.2, a.y + a.h * 0.175, a.w * 0.6, a.h * 0.65 },
          top_left     = { a.x,          a.y,          hw - g,   hh - g },
          top_right    = { a.x + hw + g, a.y,          hw - g,   hh - g },
          bottom_left  = { a.x,          a.y + hh + g, hw - g,   hh - g },
          bottom_right = { a.x + hw + g, a.y + hh + g, hw - g,   hh - g },
        }
        local z = zones[zone]
        if not z then return end

        hl.dispatch(hl.dsp.window.resize({ x = math.floor(z[3]), y = math.floor(z[4]), relative = false }))
        hl.dispatch(hl.dsp.window.move({ x = math.floor(z[1]), y = math.floor(z[2]), relative = false }))
      end

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
        -- Wallpaper (the image lives in this repo and ends up in the Nix store)
        hl.exec_cmd("sleep 1 && awww img ${./wallpapers/bg.png} --transition-type fade")
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
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

      -- Power menu
      hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("wlogout"))

      -- Clipboard history
      hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p Clipboard | cliphist decode | wl-copy"))

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

      -- Drop a floating window against a screen edge to tile it:
      -- left/right edge = half screen, top edge = maximize, corners = quarter
      local edge = 24
      hl.bind(mainMod .. " + mouse:272", function()
        local win = hl.get_active_window()
        local c = hl.get_cursor_pos()
        local mon = hl.get_monitor_at_cursor()
        if not win or not win.floating or not c or not mon then return end

        local left = c.x - mon.x < edge
        local right = mon.x + mon.width / mon.scale - c.x < edge
        local top = c.y - mon.y < edge
        local bottom = mon.y + mon.height / mon.scale - c.y < edge

        if top and left then snap("top_left")
        elseif top and right then snap("top_right")
        elseif bottom and left then snap("bottom_left")
        elseif bottom and right then snap("bottom_right")
        elseif left then snap("left")
        elseif right then snap("right")
        elseif top then snap("maximize")
        end
      end, { drag = true })

      -- Keyboard snapping
      hl.bind(mainMod .. " + ALT + left", function() snap("left") end)
      hl.bind(mainMod .. " + ALT + right", function() snap("right") end)
      hl.bind(mainMod .. " + ALT + up", function() snap("maximize") end)
      hl.bind(mainMod .. " + ALT + down", function() snap("center") end)

      -- Toggle auto-tiling (Pop!_OS style) for new windows and the current workspace
      hl.bind(mainMod .. " + T", function()
        autoTile = not autoTile
        floatRule:set_enabled(not autoTile)
        local ws = hl.get_active_workspace()
        if ws then
          for _, win in ipairs(ws:get_windows()) do
            hl.dispatch(hl.dsp.window.float({ window = win, action = autoTile and "unset" or "set" }))
          end
        end
        hl.exec_cmd("notify-send 'Auto-tiling " .. (autoTile and "on" or "off") .. "'")
      end)

      -- Media keys (swayosd shows an on-screen popup)
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
    '';

    # Home Manager's systemd integration is enabled by default.
    # Keep it enabled because we launch a normal Hyprland session.
    systemd.enable = true;
  };
}
