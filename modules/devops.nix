{ pkgs, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/mael/nixos-config";
  };

  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
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
    claude-code

    kubectl
    minikube
    kubernetes-helm
    terraform
    ansible

    python3
    nodejs
    go
    gcc
    gnumake
  ];

  # Installs the matching docker CLI; listing pkgs.docker as well would risk
  # a client/daemon version split.
  virtualisation.docker.enable = true;

  # Installs git system-wide.
  programs.git.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
