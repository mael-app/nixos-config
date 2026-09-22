{ config, lib, modulesPath, ... }:

# Written by hand to match docs/install-usb.md: every filesystem is
# referenced by label, so the drive boots regardless of the device name
# it gets (/dev/sda, /dev/sdb...) and no UUIDs need to be copied back.
#
#   NIXBOOT   FAT32 ESP (1 GiB)
#   NIXCRYPT  LUKS2 container
#   nixos     btrfs inside LUKS, subvolumes @, @home, @nix
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # USB storage drivers must be in the initrd, otherwise the root
  # filesystem on the USB SSD can't be found at boot.
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "uas"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-label/NIXCRYPT";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
