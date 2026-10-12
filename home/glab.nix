{ pkgs, ... }:

# GitLab CLI for the self-hosted instance. `glab auth login --hostname
# gitlab.logi-it.com` stores its token under ~/.config/glab-cli, which this
# repository deliberately does not manage.
{
  home.packages = [ pkgs.glab ];

  # Default host outside a repository. Inside one, glab still follows the
  # remote, so gitlab.com projects keep working.
  home.sessionVariables.GITLAB_HOST = "gitlab.logi-it.com";
}
