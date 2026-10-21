_:

# Bluetooth stack plus the applet the waybar tray talks to.
{
  hardware.bluetooth = {
    enable = true;
    # Keep the controller off until the user explicitly enables Bluetooth.
    # The waybar Bluetooth icon starts it on demand and no applet scans in the
    # background; see home/bluetooth-menu.nix.
    powerOnBoot = false;
    settings.Policy.AutoEnable = false;
  };

  services.blueman.enable = true;
}
