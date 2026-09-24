{ lib, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Maël";
      email = "mael.app@proton.me";
    };
    # Push over SSH even when a remote was cloned with an https:// URL. There
    # is no credential helper here, so an https remote would prompt for a
    # GitHub password that no longer exists.
    settings.url."git@github.com:".insteadOf = "https://github.com/";
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
      format = "ssh";
    };
  };
}
