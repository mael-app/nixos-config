{ lib, ... }:

# Faster package downloads from inside China. The SJTU mirror serves the
# official binary cache, so the paths carry the cache.nixos.org signature and
# no extra trusted-public-keys entry is needed. NixOS appends
# https://cache.nixos.org automatically, so it stays as a fallback.
{
  # Priority 10 makes this mirror win over cache.nixos.org (priority 40)
  # whenever both caches have the path. Keep the official cache as a fallback.
  nix.settings.substituters = lib.mkBefore [
    "https://mirror.sjtu.edu.cn/nix-channels/store?priority=10"
  ];
}
