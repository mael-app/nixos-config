{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Run Electron/Chromium apps (VS Code, Discord, 1Password...) as native
  # Wayland clients instead of through XWayland: sharp text with fractional
  # scaling. NixOS wrappers only add the Wayland flags when this is set.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Portals are managed here only. programs.hyprland already contributes both
  # xdg-desktop-portal-hyprland and xdg-desktop-portal-gtk, so extraPortals
  # stays empty; naming the two implementations explicitly is more
  # predictable than the "*" catch-all.
  xdg.portal = {
    enable = true;
    config.common.default = [ "hyprland" "gtk" ];
  };

  # Use the recommended Hyprland launcher rather than invoking Hyprland
  # directly. This avoids the "started without start-hyprland" warning.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/start-hyprland";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    spotify
    discord
    notion-electron
    vlc

    adwaita-icon-theme
    hicolor-icon-theme
    man-pages
    tldr

    kitty
    waybar
    rofi
    file-roller
    grimblast
    hyprpicker
    imv
    mpv

    wl-clipboard
    grim
    slurp
    pavucontrol
    networkmanagerapplet

    brightnessctl
    playerctl
    libnotify
    wlogout
    awww
    nwg-dock-hyprland
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # Thunar must come from its module: plugins are baked into the wrapper it
  # builds, so a plugin listed in environment.systemPackages is never loaded.
  # The module also pulls in programs.xfconf, which Thunar needs to persist
  # its own settings.
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-archive-plugin ];
  };

  security.polkit.enable = true;

  # 1Password: CLI + desktop app. polkitPolicyOwners enables system
  # authentication unlock and the CLI integration for this user.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "mael" ];
  };

  # hyprlock is configured by Home Manager, which only writes its config; the
  # PAM service is what lets it check the password. programs.hyprlock is not
  # used here because it would also enable the NixOS hypridle unit on top of
  # the Home Manager one.
  security.pam.services.hyprlock = { };

  # Needed for Home Manager dconf settings (dark mode for GTK4 apps)
  programs.dconf.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Battery / power info for waybar
  services.upower.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
