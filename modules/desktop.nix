{ pkgs, username, ... }:

{
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Thunar must come from its module: plugins are baked into the wrapper it
    # builds, so a plugin listed in environment.systemPackages is never loaded.
    # The module also pulls in programs.xfconf, which Thunar needs to persist
    # its own settings.
    thunar = {
      enable = true;
      plugins = [ pkgs.thunar-archive-plugin ];
    };

    gdk-pixbuf.modulePackages = [
      pkgs.libheif.lib
      pkgs.webp-pixbuf-loader
    ];

    # 1Password: CLI + desktop app. polkitPolicyOwners enables system
    # authentication unlock and the CLI integration for this user.
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
    };

    # Needed for Home Manager dconf settings (dark mode for GTK4 apps)
    dconf.enable = true;
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

  # Thunar talks to removable media, the trash and network shares through
  # gvfs. udisks2 alone only exposes the block devices; without gvfs a plugged
  # in USB stick never shows up in the sidebar and there is no trash.
  services = {
    gvfs.enable = true;
    udisks2.enable = true;

    # Thunar asks tumbler over D-Bus for image thumbnails. Tumbler decodes them
    # through GdkPixbuf, which only reads JPEG, PNG and the like out of the box:
    # the extra loaders add HEIC/AVIF (libheif ships its loader in the lib
    # output) and WebP.
    tumbler.enable = true;
    upower.enable = true;
  };

  security.polkit.enable = true;

  # hyprlock is configured by Home Manager, which only writes its config; the
  # PAM service is what lets it check the password. programs.hyprlock is not
  # used here because it would also enable the NixOS hypridle unit on top of
  # the Home Manager one.
  security.pam.services.hyprlock = { };

}
