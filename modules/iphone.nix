{ ... }:

# usbmuxd multiplexes the USB connection to iOS devices; the libimobiledevice
# tools in ../home/iphone.nix talk to the iPhone through it. It also installs
# the udev rules that start it when an iPhone is plugged in.
{
  services.usbmuxd.enable = true;
}
