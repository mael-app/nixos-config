{ ... }:

# Bluetooth stack plus the applet the waybar tray talks to.
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;
}
