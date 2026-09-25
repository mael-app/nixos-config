{ ... }:

# Bluetooth stack plus the applet the waybar tray talks to.
{
  hardware.bluetooth = {
    enable = true;
    # The controller stays off until something asks for it, which keeps
    # bluetoothd from listening on the radio during the boots where no
    # Bluetooth device is used at all. blueman powers it on on demand.
    powerOnBoot = false;
  };

  services.blueman.enable = true;
}
