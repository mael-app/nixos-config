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

  config.local.powerMenu.command = lib.concatStringsSep " " [
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
}
