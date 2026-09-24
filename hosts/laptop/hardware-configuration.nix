{ lib, modulesPath, ... }:

# Written by hand to match scripts/install-laptop.sh: everything is
# referenced by label, so nothing has to be copied back after install.
#
#   LAPBOOT     FAT32 ESP (1 GiB)
#   LAPCRYPT    LUKS2 -> btrfs "nixos-sys"  : subvolumes @ and @nix
#   LAPHOME     LUKS2 -> btrfs "nixos-home" : subvolume @home
#
# /home lives in its own LUKS container so the system can be reinstalled
# without touching personal data. Both containers get the same passphrase:
# systemd stage 1 caches it, so it is only typed once at boot. It is also
# what allows enrolling the TPM for both (see docs/install-laptop.md).
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # systemd in the initrd: passphrase caching between the two containers,
  # and required for TPM auto-unlock (systemd-cryptenroll).
  boot.initrd.systemd.enable = true;

  boot.initrd.luks.devices = {
    laptop-cryptroot = {
      device = "/dev/disk/by-label/LAPCRYPT";
      allowDiscards = true;
    };
    laptop-crypthome = {
      device = "/dev/disk/by-label/LAPHOME";
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/mapper/laptop-cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/laptop-cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/laptop-crypthome";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/LAPBOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
