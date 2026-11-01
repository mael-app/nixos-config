{
  pkgs,
  palette,
  wallpaper,
  ...
}:

let
  # Circular avatar center-cropped from the session wallpaper, so the lock
  # screen, the greeter and the desktop share the same visual anchor.
  avatar = pkgs.runCommand "hyprlock-avatar.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    magick ${wallpaper} -resize "512x512^" -gravity center -extent 512x512 $out
  '';

  # Empty output when the machine has no battery (test VM), so the label
  # simply does not show.
  battery = pkgs.writeShellScript "hyprlock-battery" ''
    for bat in /sys/class/power_supply/BAT*; do
      [ -d "$bat" ] || exit 0
      capacity="$(${pkgs.coreutils}/bin/cat "$bat/capacity")"
      status="$(${pkgs.coreutils}/bin/cat "$bat/status")"
      if [ "$status" = Charging ]; then icon="󰂄"; else icon="󰁹"; fi
      echo "$icon  $capacity%"
      exit 0
    done
  '';

  # Currently playing track, hidden when no player is running.
  media = pkgs.writeShellScript "hyprlock-media" ''
    track="$(${pkgs.playerctl}/bin/playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)" || exit 0
    [ -n "$track" ] && echo "󰎆  $track"
  '';
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          path = "screenshot";
          blur_passes = 2;
          blur_size = 4;
        }
      ];
      image = [
        {
          path = toString avatar;
          size = 140;
          # -1 turns the square crop into a circle.
          rounding = -1;
          border_size = 2;
          border_color = palette.rgb "blue";
          position = "0, 330";
          halign = "center";
          valign = "center";
        }
      ];
      label = [
        {
          text = "$TIME";
          color = palette.rgba "text" "1.0";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 170";
          halign = "center";
          valign = "center";
        }
        {
          text = ''cmd[update:60000]date +"%A %d %B"'';
          color = palette.rgba "subtext1" "1.0";
          font_size = 18;
          font_family = "Noto Sans";
          position = "0, 115";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:10000]${battery}";
          color = palette.rgba "green" "1.0";
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font";
          position = "-40, -40";
          halign = "right";
          valign = "top";
        }
        {
          text = "cmd[update:2000]${media}";
          color = palette.rgba "mauve" "1.0";
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -170";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          size = "300, 60";
          position = "0, -80";
          dots_center = true;
          fade_on_empty = false;
          outline_thickness = 2;
          outer_color = palette.rgb "blue";
          inner_color = palette.rgba "base" "0.8";
          font_color = palette.rgb "text";
          capslock_color = palette.rgb "yellow";
          check_color = palette.rgb "peach";
          fail_color = palette.rgb "red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          placeholder_text = "Password...";
        }
      ];
    };
  };
}
