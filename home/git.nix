{ lib, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Maël";
      email = "mael.app@proton.me";
    };
    # Push over SSH even when a remote was cloned with an https:// URL, so
    # github.com traffic authenticates with the SSH key rather than with the
    # token gh registers as a credential helper (see ./gh.nix). Gists are not
    # covered by the rewrite and keep using that helper.
    settings.url."git@github.com:".insteadOf = "https://github.com/";
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
      format = "ssh";
    };
  };
}
