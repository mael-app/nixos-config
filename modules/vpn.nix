{ ... }:

{
  # Mullvad VPN daemon + desktop app.
  # Log in once with `mullvad account login <number>` or from the app.
  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;
  };
}
