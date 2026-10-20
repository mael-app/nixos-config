{ config, ... }:

{
  # Keep npm global installs outside the immutable Nix store.
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.local
  '';

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
}
