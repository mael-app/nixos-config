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

  # Compressed swap in RAM instead of a swap partition (fewer SSD writes).
  zramSwap.enable = true;

  services.fstrim.enable = true;
}
