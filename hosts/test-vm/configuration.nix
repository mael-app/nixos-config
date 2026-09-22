{ lib, ... }:

{
  # QEMU/KVM VM: legacy BIOS + GRUB.
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  networking.hostName = "nixos-test";

  # Guest integration for virt-manager: SPICE clipboard sharing and the
  # QEMU guest agent (clean shutdown, IP shown in virt-manager).
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  home-manager.users.mael.wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    -- Monitor: "preferred" follows the virt-manager window size (virtio-gpu)
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.0 })

    -- Virtual GPUs often draw an invisible or offset hardware cursor
    hl.config({
      cursor = {
        no_hardware_cursors = 1,
      },
    })
  '';

  system.stateVersion = "25.11";
}
