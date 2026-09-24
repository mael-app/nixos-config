{ ... }:

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
      label = [
        {
          text = "$TIME";
          color = "rgba(205, 214, 244, 1.0)";
          font_size = 64;
          position = "0, 180";
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
          outer_color = "rgb(137, 180, 250)";
          inner_color = "rgba(30, 30, 46, 0.8)";
          font_color = "rgb(205, 214, 244)";
          placeholder_text = "Password...";
        }
      ];
    };
  };
}
