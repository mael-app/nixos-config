{ pkgs, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/mael/nixos-config";
  };

  programs.nix-index-database.comma.enable = true;

  # The toolchains and editors are mael's, so they live in Home Manager.
  # Only the two fetchers stay system-wide: NixOS puts neither on the path by
  # default (environment.defaultPackages is perl, rsync and strace), and root
  # shells and scripts expect them to exist.
  environment.systemPackages = with pkgs; [
    curl
    wget
  ];

  # Installs the matching docker CLI; listing pkgs.docker as well would risk
  # a client/daemon version split.
  virtualisation.docker.enable = true;

  # Installs git system-wide.
  programs.git.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
