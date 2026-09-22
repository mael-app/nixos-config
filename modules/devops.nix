{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    jq
    yq
    tree
    htop
    ripgrep
    fd
    tmux
    neovim
    fastfetch
    vscode
    opencode

    docker
    kubectl
    kubernetes-helm
    terraform
    ansible

    python3
    nodejs
    go
    gcc
    gnumake
  ];

  virtualisation.docker.enable = true;

  programs.git.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
