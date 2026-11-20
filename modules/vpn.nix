_:

{
  # Mullvad VPN daemon + desktop app.
  # Log in once with `mullvad account login <number>` or from the app.
  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;

    # Block all traffic from the start of boot until the daemon has its own
    # firewall in place, instead of leaving a window before it starts. This
    # is what upstream ships on the distributions it supports; NixOS leaves
    # it off only because it can clash with custom network setups.
    enableEarlyBootBlocking = true;

    # mullvad-exclude is a setuid root wrapper that lets any program on the
    # machine run outside the tunnel. Nothing here uses it, and a process that
    # wants to leak traffic past the VPN should not be handed a way to.
    enableExcludeWrapper = false;
  };

  # Keep access to the LAN outside the Mullvad tunnel. The main route table
  # selects Ethernet for this network when the wired connection is available.
  #
  # Only packets that already leave outside the tunnel are marked. Mullvad's
  # `suppress_prefixlength 0` rule lets a route for this subnet in the main
  # table win only while the machine is actually on it; on any other network
  # the first lookup picks wg0-mullvad, and marking those packets would send
  # them to that network's gateway in the clear instead.
  networking.nftables = {
    enable = true;
    ruleset = ''
      define ETHERNET_LAN = 172.29.94.0/24

      table inet mullvad-ethernet-exclude {
        chain excludeOutgoing {
          type route hook output priority -10; policy accept;
          ip daddr $ETHERNET_LAN oifname != "wg0-mullvad" ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
        }
      }
    '';
  };
}
