{ pkgs, ... }:

# Hardware settings for the laptop itself (Intel Raptor Lake, Iris Xe),
# shared by the USB drive and the internal disk installs.
{
  # Wi-Fi, Bluetooth and GPU firmware.
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  hardware.graphics = {
    enable = true;
    # Hardware video decoding (VA-API) on Intel Iris Xe.
    extraPackages = [ pkgs.intel-media-driver ];
  };

  # Power management and firmware updates.
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;

  # Raptor Lake throttles hard without an active thermal policy.
  services.thermald.enable = true;

  # Compressed swap in RAM instead of a swap partition (fewer SSD writes).
  zramSwap.enable = true;

  services.fstrim.enable = true;

  # Both installs put / , /nix and /home on btrfs. Scrub them monthly to catch
  # silent corruption while it is still only a checksum error. The mount points
  # are listed per host, because the default scrubs every btrfs mount and these
  # layouts keep several subvolumes on a single device.
  services.btrfs.autoScrub.enable = true;

  # NixOS generations roll the system back, but nothing covers /home. Snapper
  # keeps a timeline of read-only snapshots in /home/.snapshots; they live on
  # the same disk, so this protects against mistakes, not against disk loss.
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    ALLOW_USERS = [ "mael" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 6;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 3;
    TIMELINE_LIMIT_YEARLY = 0;
  };
}
