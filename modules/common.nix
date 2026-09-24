{ lib, ... }:

# Settings shared by every machine.
{
  networking.networkmanager.enable = true;

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
    ];

  security.sudo.wheelNeedsPassword = true;
}
