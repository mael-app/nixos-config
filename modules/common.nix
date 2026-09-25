{ lib, host, ... }:

# Settings shared by every machine.
{
  # The flake names each configuration after the machine it builds, so the
  # hostname is that name and is never written twice.
  networking.hostName = host;

  networking.networkmanager = {
    enable = true;

    # Present a different MAC address to every network instead of the
    # permanent one, so a Wi-Fi access point cannot recognise this machine
    # across visits. "stable" derives the address from the connection
    # profile, which keeps DHCP reservations and MAC filtering working;
    # "random" would draw a new one on every connection.
    wifi.macAddress = "stable";
  };

  # Neither is used here: names are resolved by DNS, and nothing on the local
  # network is looked up by hostname. Both make resolved parse unauthenticated
  # multicast traffic from anyone on the same Wi-Fi, so they are pure attack
  # surface on a public network.
  services.resolved.settings.Resolve = {
    LLMNR = "no";
    MulticastDNS = "no";
  };

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";

  # TTY / login keyboard. useXkbConfig derives the console keymap from the
  # layout below instead of repeating it as console.keyMap.
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.useXkbConfig = true;

  # Nix CLI + flakes globally enabled.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Prebuilt output for packages that cache.nixos.org does not carry, chiefly
  # the nix-community projects this flake pulls in. The public key is what
  # makes it safe to trust a third-party store.
  #
  # The Hyprland and nix-gaming caches are deliberately absent: Hyprland comes
  # from nixpkgs here, so its own cache would never be consulted.
  nix.settings = {
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Silence "Git tree is dirty". Evaluating this flake with uncommitted work is
  # the normal way to test a change before committing it, and the warning says
  # nothing beyond that. system.configurationRevision already falls back to
  # dirtyRev, so a generation built this way is still identifiable.
  nix.settings.warn-dirty = false;

  # Keep the Nix store small: dedupe identical files and drop old
  # generations every week.
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Only the non-free packages we explicitly use.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
      "terraform"
      "vscode"
      "discord"
      "discord-unwrapped"
      "1password"
      "1password-cli"
      "claude-code"
      "steam"
      "steam-unwrapped"
      "lunarclient"
    ];

  security.sudo.wheelNeedsPassword = true;

  # /tmp is a subvolume of the root filesystem here, so whatever an
  # application leaves there survives a reboot and keeps accumulating on the
  # disk. Wiping it at boot bounds both the leftovers and the data they hold.
  boot.tmp.cleanOnBoot = true;
}
