{ pkgs, username, ... }:

# Gaming, on the machines that have the laptop's GPU. Not imported by the
# test VM, which has no use for a Proton sized closure.
{
  # Games running through Proton regularly execute "split locked"
  # instructions, which the kernel slows down hard by default
  # (kernel.split_lock_mitigate). Windows 11 applies no such penalty, so
  # leaving detection on is one of the few ways this machine can be slower
  # than its Windows install. The mitigation protects multi-tenant hosts
  # from cross-VM denial of service, which is not a threat on a personal
  # laptop, so matching Windows behaviour here costs nothing real.
  boot.kernelParams = [ "split_lock_detect=off" ];

  programs = {
    # GameMode asks power-profiles-daemon for the performance profile while a
    # game runs and restores the previous one on exit, so a gaming session no
    # longer depends on remembering the profile buttons in the notification
    # center. Games opt in per title with `gamemoderun %command%` in their
    # Steam launch options, or `gamemoderun <cmd>` anywhere else.
    gamemode.enable = true;

    gamescope.enable = true;

    # The module is what makes Steam work: it wraps the client with the FHS
    # environment it expects and turns on hardware.graphics.enable32Bit, which
    # the 32-bit half of Proton and older titles need. Installing the package
    # on its own gives a client that cannot run most of the library.
    steam = {
      enable = true;

      # Every openFirewall here stays at its default of false. Remote Play,
      # local network game transfers and dedicated servers each want inbound
      # ports, and none of them is used on this machine; opening them would
      # undo what ./common.nix narrows elsewhere. Turn one on the day the
      # feature is actually wanted.

      # Proton is what runs Windows titles. The stock one ships with Steam;
      # this adds the community build, which carries the media codecs and
      # patches Valve cannot distribute, selectable per game under
      # Compatibility.
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };

  # The in-tree hid_xpad driver pairs unreliably with the Xbox wireless
  # controllers over Bluetooth and gets force feedback wrong. xpadneo replaces
  # it with an out-of-tree module that pairs cleanly and maps the triggers and
  # the rumble the way games expect. Wired controllers do not need it, and the
  # udev rules they rely on already come from programs.steam above.
  hardware.xpadneo.enable = true;

  # The launchers are plain user applications, so they are installed for the
  # account rather than system wide. They live here instead of
  # ../home/packages.nix because that file is shared by every host and this
  # module is not: the store fetchers and the launchers belong to the same
  # subject. Each one brings its own JRE, so no system JDK is needed.
  #
  # Mojang's own launcher used to be packaged as pkgs.minecraft; nixpkgs
  # removed it as broken and points at Prism instead. Prism signs in with the
  # same Microsoft account and runs the official Mojang version manifest, so
  # it is the vanilla launcher on this machine.
  home-manager.users.${username}.home.packages = [
    pkgs.heroic
    pkgs.lunar-client
    pkgs.prismlauncher
  ];
}
