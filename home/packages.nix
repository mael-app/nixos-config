{ pkgs, lib, ... }:

{
  # Everything mael runs. Fonts, icon fallbacks and anything another user or
  # a system service needs stay in the NixOS modules instead.
  #
  # Applications owned by a Home Manager module are not repeated here: kitty,
  # rofi, waybar, wlogout, hyprlock and the tray applets all come with theirs.
  home.packages = with pkgs; [
    # Desktop applications
    firefox
    discord
    notion-electron
    spotify
    qbittorrent
    vlc
    mpv
    imv
    file-roller
    pavucontrol

    # Wallpaper daemon and dock, started by the user services below
    awww
    nwg-dock-hyprland

    # services.network-manager-applet only references the store path from its
    # unit, so the package is needed here for nm-connection-editor, which the
    # tray icon opens from its context menu.
    networkmanagerapplet

    # ALT + Tab window switcher, started by the user service below
    hyprshell

    # Bound to keys in the Hyprland configuration further down
    grim
    slurp
    grimblast
    hyprpicker
    wl-clipboard
    brightnessctl
    playerctl
    libnotify

    # Editors and terminal tools
    vscode
    neovim
    tmux
    btop
    htop
    fastfetch
    tldr
    tree
    jq
    yq
    ripgrep
    fd

    # AI coding assistants
    claude-code
    opencode

    # Infrastructure. minikube ships its own bin/kubectl, which collides with
    # the standalone one; lowPrio lets the explicit kubectl win. NixOS builds
    # environment.systemPackages with ignoreCollisions, so this clash was
    # silently resolved at random while these lived there.
    kubectl
    (lib.lowPrio minikube)
    kubernetes-helm
    terraform
    ansible

    # Language toolchains
    python3
    nodejs
    go
    gcc
    gnumake
  ];
}
