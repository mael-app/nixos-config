{ ... }:

{
  # Mullvad VPN daemon + desktop app.
  # Log in once with `mullvad account login <number>` or from the app.
  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;
  };

  # Keep access to the LAN outside the Mullvad tunnel. The main route table
  # selects Ethernet for this network when the wired connection is available.
  networking.nftables = {
    enable = true;
    ruleset = ''
      define ETHERNET_LAN = 172.29.94.0/24

      table inet mullvad-ethernet-exclude {
        chain excludeOutgoing {
          type route hook output priority -10; policy accept;
          ip daddr $ETHERNET_LAN ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
        }
      }
    '';
  };
}
