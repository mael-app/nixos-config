{ pkgs, username, ... }:

# MangoHud: an in-game overlay for frame rate, frame times and GPU/CPU load,
# which can also record a benchmark log. It is started per game from Steam
# with the launch option `mangohud %command%`, never session wide.
{
  # Steam runs games inside its own FHS environment, which does not see the
  # account's Home Manager profile. Adding the package here puts the mangohud
  # command and its Vulkan layer where the launch option and the Steam Linux
  # Runtime can find them.
  programs.steam.extraPackages = [ pkgs.mangohud ];

  # The package on the account's own PATH, plus the configuration, which every
  # game reads from ~/.config/MangoHud/MangoHud.conf.
  home-manager.users.${username} = {
    # MangoHud does not create the log folder, and a log with nowhere to go is
    # silently dropped.
    systemd.user.tmpfiles.rules = [ "d %h/Documents/mangohud - - - -" ];

    programs.mangohud = {
      enable = true;

      # A single compact line in the top-left corner rather than the default
      # column of tables, so the overlay stays out of the crosshair and the
      # minimap.
      settings = {
        horizontal = true;
        hud_compact = true;
        hud_no_margin = true;
        position = "top-left";
        font_size = 16;
        background_alpha = 0.4;
        round_corners = 4;

        fps = true;
        # Average and 1% low, the two figures a benchmark is judged on.
        fps_metrics = "avg,0.01";
        frametime = true;
        frame_timing = true;
        gpu_stats = true;
        gpu_core_clock = true;
        cpu_stats = true;
        cpu_temp = true;
        # Shows when the CPU is power or thermal limited, which is what caps the
        # frame rate on a shared CPU and GPU package.
        throttling_status = true;

        # Right Shift + F12 shows or hides the overlay. Left Shift + F2 starts
        # and stops a log, which also stops by itself after a minute so runs are
        # comparable. Logs are CSV files with a summary of the average and the
        # 1% and 0.1% lows.
        toggle_hud = "Shift_R+F12";
        toggle_logging = "Shift_L+F2";
        log_duration = 60;
        output_folder = "/home/${username}/Documents/mangohud";
      };
    };
  };
}
