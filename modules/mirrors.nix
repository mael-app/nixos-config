{ lib, ... }:

# Faster package downloads from inside China. The TUNA mirror serves the
# official binary cache verbatim, so the paths carry the cache.nixos.org
# signature and no extra trusted-public-keys entry is needed. NixOS appends
# https://cache.nixos.org automatically, so it stays as a fallback.
{
  # mkBefore so the mirror is consulted first: Nix fetches from the first
  # substituter that has the path.
  nix.settings.substituters = lib.mkBefore [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];
}
