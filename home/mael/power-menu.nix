{
  config,
  lib,
  pkgs,
  ...
}:

# The power menu has two entry points, the waybar button and SUPER + Escape,
# so the command is built once here. wlogout sizes itself with absolute pixel
# margins, which is why the geometry is a per-host option: see
# hosts/<name>/configuration.nix.
let
  cfg = config.local.powerMenu;
in
{
  options.local.powerMenu = {
    verticalMargin = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 620;
      description = ''
        Pixels left clear above and below the row of buttons. The default
        suits the laptop panel at 2560x1600 with scale 1; a host with a
        smaller logical resolution has to lower it or the buttons are clipped.
      '';
    };

    horizontalMargin = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 620;
      description = "Pixels left clear to the left and right of the buttons.";
    };

    command = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "The command that opens the power menu.";
    };
  };

  config = {
    local.powerMenu.command = lib.concatStringsSep " " [
      "${pkgs.wlogout}/bin/wlogout"

      # -b must divide the number of layout entries. wlogout builds a full
      # buttons-per-row x ceil(n / buttons-per-row) grid and fills the leftover
      # cells from uninitialised entries of its button array, which shows up as
      # a blank tile that crashes on click. Five entries, five per row.
      "-b 5"

      "-c 24"
      "-r 24"

      "-T ${toString cfg.verticalMargin}"
      "-B ${toString cfg.verticalMargin}"
      "-L ${toString cfg.horizontalMargin}"
      "-R ${toString cfg.horizontalMargin}"
    ];

    # Power menu, opened from the waybar power button and SUPER + Escape.
    # The blurred backdrop comes from the wlogout layer rule further down in the
    # Hyprland configuration; layer surfaces are not blurred by default.
    programs.wlogout =
      let
        # The bundled SVG assets carry no fill attribute, so GTK paints them
        # black and they disappear on a dark button. Recolour them at build time
        # rather than vendoring our own copies: one set for the resting button,
        # one for the inverted hover state.
        #
        # They are rasterised here instead of being referenced as SVG, because
        # loading an SVG needs the librsvg gdk-pixbuf loader and wlogout is not
        # wrapped. Started from the waybar button it inherits waybar's
        # GDK_PIXBUF_MODULE_FILE and the icons appear; started from SUPER +
        # Escape there is no such variable, gdk-pixbuf falls back to its built-in
        # loaders, and the icons silently do not render. PNG is built in, so the
        # same menu now looks the same whoever launches it.
        icons = pkgs.runCommand "wlogout-icons" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
          mkdir -p "$out"
          for name in lock logout suspend reboot shutdown; do
            svg="${pkgs.wlogout}/share/wlogout/assets/$name.svg"
            sed 's|<svg |<svg fill="#cdd6f4" |' "$svg" > resting.svg
            sed 's|<svg |<svg fill="#1e1e2e" |' "$svg" > active.svg
            # Rendered well above the 64px the stylesheet draws them at, so the
            # tiles stay sharp on a scaled monitor.
            rsvg-convert -w 192 -h 192 -o "$out/$name.png" resting.svg
            rsvg-convert -w 192 -h 192 -o "$out/$name-active.png" active.svg
          done
        '';

        icon = label: ''
          #${label} {
            background-image: url("${icons}/${label}.png");
          }

          #${label}:hover,
          #${label}:focus {
            background-image: url("${icons}/${label}-active.png");
          }
        '';
      in
      {
        enable = true;

        layout = [
          {
            label = "lock";
            action = "loginctl lock-session";
            text = "Lock";
            keybind = "l";
          }
          {
            label = "logout";
            action = "loginctl terminate-user $USER";
            text = "Log out";
            keybind = "e";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
          }
          {
            label = "reboot";
            action = "systemctl reboot";
            text = "Reboot";
            keybind = "r";
          }
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shut down";
            keybind = "s";
          }
        ];

        style = ''
          * {
            background-image: none;
            box-shadow: none;
          }

          /* Hyprland blurs what is behind this surface, so the sheet needs a
             tint to frost: a fully transparent window leaves the desktop sharp. */
          window {
            background-color: rgba(17, 17, 27, 0.55);
          }

          button {
            font-family: "JetBrainsMono Nerd Font";
            color: #cdd6f4;
            background-color: rgba(30, 30, 46, 0.96);
            border: 2px solid rgba(137, 180, 250, 0.28);
            border-radius: 12px;
            background-repeat: no-repeat;
            /* An absolute size keeps the icon sane whatever aspect ratio the
               tiles end up with; a percentage scales with the tile. */
            background-position: center 38%;
            background-size: 64px;
            min-width: 120px;
            min-height: 100px;
            margin: 4px;
            padding: 0;
            font-size: 15px;
            font-weight: 600;
          }

          button:hover,
          button:focus {
            color: #1e1e2e;
            background-color: #89b4fa;
            border-color: #89b4fa;
            outline: none;
          }

          ${lib.concatMapStringsSep "\n" icon [
            "lock"
            "logout"
            "suspend"
            "reboot"
            "shutdown"
          ]}
        '';
      };
  };
}
