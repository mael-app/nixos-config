{ lib, username, ... }:

# NixOS on the laptop's internal 1 TB NVMe (replaces Pop!_OS).
# Windows stays untouched on the second NVMe.
{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  # Internal install: register NixOS in the firmware so it boots by default.
  boot.loader.efi.canTouchEfiVariables = true;

  # / and /nix are subvolumes of the same LUKS container, so scrubbing both
  # would read laptop-cryptroot twice. /home is a separate container.
  services.btrfs.autoScrub.fileSystems = [
    "/"
    "/home"
  ];

  # Keep the digital microphone and hide the duplicate stereo capture node.
  services.pipewire.wireplumber.extraConfig."20-hide-stereo-microphone" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source";
          }
        ];
        actions = {
          update-props = {
            "node.disabled" = true;
          };
        };
      }
      {
        matches = [
          {
            "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink";
          }
          {
            "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI2__sink";
          }
          {
            "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI3__sink";
          }
        ];
        actions = {
          update-props = {
            "node.disabled" = true;
          };
        };
      }
    ];
  };

  home-manager.users.${username}.wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    -- Laptop screen: 2560x1600. Use integer scaling for crisp dock icons.
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
  '';

  system.stateVersion = "25.11";
}
