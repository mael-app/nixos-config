{ ... }:

# GitHub CLI. `gh auth login` stores its token under ~/.config/gh, which this
# repository deliberately does not manage.
{
  programs.gh = {
    enable = true;

    settings = {
      # Clone over SSH rather than HTTPS, which matches the rewrite rule in
      # ./git.nix: every github.com remote ends up on SSH anyway, and this
      # keeps `gh repo clone` from writing an HTTPS URL that git then has to
      # translate on every fetch.
      git_protocol = "ssh";

      editor = "nvim";
    };
  };
}
