{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Hyprland 0.55+ uses Lua configuration.
  #
  # Explicitly set configType because home.stateVersion is kept at 25.11
  # and Home Manager would otherwise default this configuration to hyprlang.
  wayland.windowManager.hyprland = {
    enable = true;

    # Hyprland and its portal are already installed by the NixOS module above.
    # portalPackage = null keeps Home Manager from enabling a second,
    # user-level xdg.portal whose portals.conf would shadow the system one.
    package = null;
    portalPackage = null;

    configType = "lua";

    # We use the current Hyprland Lua API directly. This avoids generating
    # the old hyprland.conf format.
    extraConfig = ''
      -- Mael's Hyprland configuration
      -- Hyprland 0.55+ / Lua
      -- Reference: https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

      local mainMod = "SUPER"

      -- Monitor rules are per machine, see hosts/<name>/configuration.nix

      hl.config({
        input = {
          kb_layout = "fr",
          kb_variant = "",
          sensitivity = 0,

          -- Click to focus. Every window here floats and the window.active
          -- hook below raises whatever gains focus, so focus following the
          -- cursor meant merely crossing a window pulled it to the front.
          -- Focus now changes on a click, on ALT + Tab and on the SUPER
          -- movement binds, all of which are deliberate.
          follow_mouse = 0,

          -- follow_mouse = 0 still lets the cursor take focus when a
          -- workspace changes or a window closes. Turning that off keeps the
          -- rule to just the three deliberate ways above.
          mouse_refocus = false,
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

          -- hyprshell darkens the whole screen behind the ALT + Tab switcher by
          -- applying a dim_around layer rule to itself, and offers no setting to
          -- turn that off. Zeroing the strength here removes the effect without
          -- fighting over the rule, which hyprshell reapplies on every reload.
          -- Nothing else in this configuration asks for dim_around.
          dim_around = 0,
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

      -- Touchpad: 3-finger horizontal swipe switches workspaces
      hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace",
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

      -- Power menu backdrop: layer surfaces are never blurred unless a rule
      -- asks for it, so wlogout would otherwise sit on a flat tinted sheet.
      hl.layer_rule({
        name = "wlogout-blur",
        match = { namespace = "^wlogout$" },
        blur = true,
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

      -- Nothing is autostarted from here. The wallpaper daemon, the dock, the
      -- window switcher and the tray applets are all Home Manager user
      -- services bound to graphical-session.target.

      -- Raise the focused window above its neighbours. Hyprland keeps the
      -- stacking order of floating windows when focus moves, so a window
      -- picked in the switcher would otherwise stay behind whatever was
      -- covering it. The dispatcher is a no-op for tiled windows.
      hl.on("window.active", function()
        if hl.get_active_window() then
          hl.dispatch(hl.dsp.window.bring_to_top())
        end
      end)

      -- Terminal
      hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))

      -- Application launcher
      hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))

      -- File manager
      hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))

      -- Window management
      hl.bind(mainMod .. " + C", hl.dsp.window.close())
      hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
      hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
      hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

      -- Screenshots
      hl.bind("Print", hl.dsp.exec_cmd("grimblast copy area"))
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grimblast save output"))
      hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker | wl-copy"))

      -- Lock screen
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

      -- Power menu
      hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("${config.local.powerMenu.command}"))

      -- Clipboard history
      hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p Clipboard | cliphist decode | wl-copy"))

      -- Notification center
      hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

      -- Exit Hyprland
      hl.bind(mainMod .. " + M", hl.dsp.exit())

      -- Window focus
      hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

      -- ALT + Tab is intentionally missing: the hyprshell service binds it to
      -- the window switcher and rebinds it after every configuration reload.

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
      hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d kbd_backlight set 5%+"), { locked = true, repeating = true })
      hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d kbd_backlight set 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
    '';

    # Home Manager's systemd integration is enabled by default.
    # Keep it enabled because we launch a normal Hyprland session.
    systemd.enable = true;
  };
}
