{ pkgs, ... }:

# Roblox has no native Linux client and no nixpkgs package for the game. Sober
# is the unofficial client that runs the Android build through a compatibility
# layer, and upstream ships it as a Flatpak and nowhere else, so Flatpak is
# what brings it in. The nixpkgs package vinegar only covers Roblox Studio.
#
# Only the machines with the laptop's GPU get this, so the module is imported
# next to ../modules/gaming.nix rather than from ../modules/desktop.nix.
{
  # Pulls in flatpak, fuse and the system helper. The XDG portal this asserts
  # on is already enabled by ../modules/desktop.nix.
  services.flatpak.enable = true;

  # Flatpak has no declarative option for remotes or packages, so a oneshot
  # adds Flathub and installs Sober on the first boot where it is missing.
  # ConditionPathExists skips the unit once the app directory exists, which
  # keeps later boots from reaching out to the remote; flatpak update is a
  # deliberate manual step instead, as is the case for every other Flatpak.
  systemd.services.flatpak-sober = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    unitConfig.ConditionPathExists = "!/var/lib/flatpak/app/org.vinegarhq.Sober";
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      flatpak install --system -y flathub org.vinegarhq.Sober
    '';
  };
}
