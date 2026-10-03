{ pkgs, ... }:

let
  # libtatsu 1.0.5 requests a Yonkers ticket for every Yonkers component, which
  # the signing server refuses on Face ID iPhones, so restores abort with
  # "Unable to fetch Yonkers ticket". Upstream fixed it after the release by
  # restricting the request to the SysTopPatch components.
  libtatsu = pkgs.libtatsu.overrideAttrs {
    version = "1.0.5-unstable-2026-09-07";
    src = pkgs.fetchFromGitHub {
      owner = "libimobiledevice";
      repo = "libtatsu";
      rev = "e7d6ad13ef928aa609d0ccdfc586f7d6e8e049bf";
      hash = "sha256-etm/bxCjWw1z5az3YfKzV5BEIJDpyWyChljP2bJeCYQ=";
    };
  };
  # idevicerestore gets libtatsu through libimobiledevice.
  libimobiledevice = pkgs.libimobiledevice.override { inherit libtatsu; };
in
{
  # iPhone management without macOS: backups (idevicebackup2) and iOS updates
  # or restores over USB (idevicerestore). They need usbmuxd from
  # ../modules/iphone.nix.
  home.packages = [
    libimobiledevice
    (pkgs.idevicerestore.override { inherit libimobiledevice; })
  ];
}
