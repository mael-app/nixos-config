{ lib }:

# Catppuccin Mocha: the single source of truth for every color the desktop
# paints. Waybar, the dock, swaync, wlogout, rofi, hyprlock, Hyprland's
# borders, ghostty, fzf and starship all read from here, so a theme change
# is a one-file edit. flake.nix passes this attrset to every module.
let
  colors = {
    rosewater = "f5e0dc";
    flamingo = "f2cdcd";
    pink = "f5c2e7";
    mauve = "cba6f7";
    red = "f38ba8";
    maroon = "eba0ac";
    peach = "fab387";
    yellow = "f9e2af";
    green = "a6e3a1";
    teal = "94e2d5";
    sky = "89dceb";
    sapphire = "74c7ec";
    blue = "89b4fa";
    lavender = "b4befe";

    text = "cdd6f4";
    subtext1 = "bac2de";
    subtext0 = "a6adc8";
    overlay2 = "9399b2";
    overlay1 = "7f849c";
    overlay0 = "6c7086";
    surface2 = "585b70";
    surface1 = "45475a";
    surface0 = "313244";
    base = "1e1e2e";
    mantle = "181825";
    crust = "11111b";
  };

  byte = hex: start: toString (lib.fromHexString (builtins.substring start 2 hex));
in
rec {
  inherit colors;

  # "#89b4fa"
  hex = name: "#${colors.${name}}";

  # "137, 180, 250", for CSS rgba() in GTK stylesheets
  channels =
    name:
    let
      color = colors.${name};
    in
    "${byte color 0}, ${byte color 2}, ${byte color 4}";

  # "rgb(137, 180, 250)"
  rgb = name: "rgb(${channels name})";

  # "rgba(137, 180, 250, 0.8)". The alpha is a string so the output keeps
  # exactly the precision it was written with.
  rgba = name: alpha: "rgba(${channels name}, ${alpha})";

  # "rgba(89b4faee)": Hyprland's hex-plus-alpha notation, alpha as "ee"
  hypr = name: alpha: "rgba(${colors.${name}}${alpha})";
}
