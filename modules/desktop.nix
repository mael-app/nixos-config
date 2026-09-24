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

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
    swaynotificationcenter
    thunar
    file-roller
    thunar-archive-plugin

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
    swaylock-effects
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  security.polkit.enable = true;

  # 1Password: CLI + desktop app. polkitPolicyOwners enables system
  # authentication unlock and the CLI integration for this user.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "mael" ];
  };

  # Without this PAM service swaylock can't check the password to unlock
  security.pam.services.swaylock = { };

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
