{ pkgs, config, ... }:

# Rust toolchain from nixpkgs. It links with the gcc in ./packages.nix.
{
  home.packages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
  ];

  # `cargo install` puts its binaries here.
  home.sessionPath = [ "${config.home.homeDirectory}/.cargo/bin" ];
}
