{ pkgs, lib, ... }:

{
  # Everything mael runs. Fonts, icon fallbacks and anything another user or
  # a system service needs stay in the NixOS modules instead.
  #
  # Applications owned by a Home Manager module are not repeated here: ghostty,
  # rofi, waybar, wlogout, hyprlock and the tray applets all come with theirs.
  home.packages = with pkgs; [
    # Desktop applications
    discord
    signal-desktop
    wechat
    notion-electron
    termius
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

    # Bound to keys in the Hyprland configuration further down
    grim
    slurp
    grimblast
    hyprpicker
    wtype
    wl-clipboard
    brightnessctl
    playerctl
    libnotify

    # ALT + Tab window selector, started by the user service below
    hyprshell

    # Editors and terminal tools
    vscode
    jetbrains.rider
    neovim
    tmux
    btop
    htop
    fastfetch
    tldr
    tree
    jq
    yq
    unzip
    ripgrep
    fd
    bind

    # AI coding assistants
    claude-code
    opencode
    # Compresses command output before the agents read it, cutting tokens.
    rtk

    # Infrastructure. minikube ships its own bin/kubectl, which collides with
    # the standalone one; lowPrio lets the explicit kubectl win. NixOS builds
    # environment.systemPackages with ignoreCollisions, so this clash was
    # silently resolved at random while these lived there.
    kubectl
    (lib.lowPrio minikube)
    kubernetes-helm
    terraform
    opentofu
    ansible

    # Language toolchains
    python3
    ruby
    nodejs
    go
    gcc
    gnumake
    # Nix language server, used by the editors and by opencode's LSP.
    nixd
  ];
}
