{ lib, palette, ... }:

# Interactive shell: zsh for completion and plugins, starship for the prompt,
# direnv for per-project environments, and the modern CLI replacements
# (eza, bat, fzf, zoxide) all sharing the desktop palette.
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
      };
      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        lt = "eza --tree --level=2";
        cat = "bat";
      };
    };

    # Starship renders the prompt; oh-my-zsh is kept only for its plugins.
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # The whole Catppuccin Mocha table, so module styles below can name
        # colors instead of repeating hex codes.
        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha = lib.mapAttrs (_: color: "#${color}") palette.colors;

        format = "$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character";

        directory = {
          style = "blue";
          truncation_length = 4;
          read_only = " 󰌾";
        };
        git_branch = {
          symbol = "󰘬 ";
          style = "mauve";
          format = "[$symbol$branch(:$remote_branch)]($style) ";
        };
        git_status = {
          style = "yellow";
          format = "([$all_status$ahead_behind]($style) )";
        };
        nix_shell = {
          symbol = "󱄅 ";
          style = "sky";
          format = "[$symbol$state( \\($name\\))]($style) ";
        };
        cmd_duration = {
          min_time = 2000;
          style = "yellow";
          format = "[took $duration]($style) ";
        };
        character = {
          success_symbol = "[❯](green)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    bat.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        "bg+" = palette.hex "surface0";
        bg = palette.hex "base";
        spinner = palette.hex "rosewater";
        hl = palette.hex "red";
        fg = palette.hex "text";
        header = palette.hex "red";
        info = palette.hex "mauve";
        pointer = palette.hex "rosewater";
        marker = palette.hex "rosewater";
        "fg+" = palette.hex "text";
        prompt = palette.hex "mauve";
        "hl+" = palette.hex "red";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
