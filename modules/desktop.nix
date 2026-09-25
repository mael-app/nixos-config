{ pkgs, username, ... }:

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
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  # Only what the system itself needs. Everything the desktop account runs is
  # installed by Home Manager, so `home-manager switch` can update it without
  # rebuilding the system; see ../home.
  environment.systemPackages = with pkgs; [
    # Icon fallbacks every GTK application expects to find, including those
    # run by other users such as the greeter.
    adwaita-icon-theme
    hicolor-icon-theme

    man-pages
  ];

  # Thunar must come from its module: plugins are baked into the wrapper it
  # builds, so a plugin listed in environment.systemPackages is never loaded.
  # The module also pulls in programs.xfconf, which Thunar needs to persist
  # its own settings.
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-archive-plugin ];
  };

  # Thunar talks to removable media, the trash and network shares through
  # gvfs. udisks2 alone only exposes the block devices; without gvfs a plugged
  # in USB stick never shows up in the sidebar and there is no trash.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  security.polkit.enable = true;

  # 1Password: CLI + desktop app. polkitPolicyOwners enables system
  # authentication unlock and the CLI integration for this user.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ username ];
  };

  # hyprlock is configured by Home Manager, which only writes its config; the
  # PAM service is what lets it check the password. programs.hyprlock is not
  # used here because it would also enable the NixOS hypridle unit on top of
  # the Home Manager one.
  security.pam.services.hyprlock = { };

  # Needed for Home Manager dconf settings (dark mode for GTK4 apps)
  programs.dconf.enable = true;

  # Battery / power info for waybar
  services.upower.enable = true;
}
