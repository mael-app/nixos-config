{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  # Git credential helper backed by the 1Password CLI. GitHub traffic goes
  # over SSH, but the self-hosted GitLab only speaks HTTPS, and 1Password has
  # no official git plugin, so the personal access token is read on demand
  # from a Login item instead of being cached in ~/.git-credentials.
  #
  # The setgid wrapper is used rather than the plain package: the CLI reaches
  # the desktop app through a socket owned by the onepassword-cli group.
  gitlabCredentialHelper = pkgs.writeShellScript "git-credential-1password" ''
    case "$1" in
      get)
        token="$(${osConfig.security.wrapperDir}/op read 'op://Personal/GitLab LogIT PAT/password')" || exit 1
        printf 'username=oauth2\npassword=%s\n' "$token"
        ;;
      *) : ;;
    esac
  '';
in

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Maël";
      email = "mael.app@proton.me";
    };
    # Push over SSH even when a remote was cloned with an https:// URL, so
    # GitHub and GitLab.com authenticate with the SSH key rather than with a
    # token registered as a credential helper. Gists are not covered by the
    # GitHub rewrite and keep using that helper.
    settings.url."git@github.com:".insteadOf = "https://github.com/";
    settings.url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
    # SSH to this GitLab does not work, so its remotes stay on HTTPS and
    # authenticate with a personal access token. The token lives in the
    # "GitLab LogIT PAT" 1Password item and is read by the helper above, so
    # nothing is written to ~/.git-credentials. Commits are still signed with
    # the SSH key.
    settings.credential."https://gitlab.logi-it.com".helper =
      lib.getExe' gitlabCredentialHelper "git-credential-1password";
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
      format = "ssh";
    };
  };
}
