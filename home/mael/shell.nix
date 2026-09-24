{ ... }:

# Interactive shell: zsh for completion and plugins, starship for the prompt,
# direnv for per-project environments.
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  # Starship renders the prompt; oh-my-zsh is kept only for its plugins.
  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
