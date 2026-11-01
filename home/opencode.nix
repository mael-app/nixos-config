{ inputs, palette, ... }:

let
  # OpenCode's theme loader supports named definitions and expects both
  # variants even when the desktop is intentionally dark-only.
  color = name: {
    dark = palette.hex name;
    light = palette.hex name;
  };
in
{
  # OpenCode 2 reads the CLI theme from cli.json. Keep the theme declarative
  # and use the same Catppuccin colors as Ghostty, Waybar and SwayNC.
  programs.opencode = {
    enable = true;
    package = null;
    # Keep cli.json writable by OpenCode. The declarative layer is injected
    # through OPENCODE_CLI_CONFIG_CONTENT, so activation no longer moves the
    # user's existing cli.json to a .hm-bak file.
    mutableSettings = true;
    cli = {
      theme = {
        name = "catppuccin-mael";
        mode = "dark";
      };
    };
    themes.catppuccin-mael = {
      defs = palette.colors;
      theme = {
        primary = color "blue";
        secondary = color "mauve";
        accent = color "peach";
        text = color "text";
        textMuted = color "subtext0";
        background = color "base";
        backgroundPanel = color "mantle";
        backgroundElement = color "surface0";
        border = color "surface1";
        borderActive = color "blue";
        borderSubtle = color "surface0";
        success = color "green";
        error = color "red";
        warning = color "yellow";
        info = color "sky";
        selectedListItemText = color "base";
        diffAdded = color "green";
        diffAddedBg = color "surface0";
        diffAddedLineNumberBg = color "surface0";
        diffContext = color "overlay1";
        diffContextBg = color "base";
        diffHighlightAdded = color "green";
        diffHighlightRemoved = color "red";
        diffHunkHeader = color "blue";
        diffLineNumber = color "overlay1";
        diffRemoved = color "red";
        diffRemovedBg = color "surface0";
        diffRemovedLineNumberBg = color "surface0";
        markdownBlockQuote = color "overlay1";
        markdownCode = color "green";
        markdownCodeBlock = color "surface0";
        markdownEmph = color "peach";
        markdownHeading = color "blue";
        markdownHorizontalRule = color "surface1";
        markdownImage = color "mauve";
        markdownImageText = color "pink";
        markdownLink = color "sapphire";
        markdownLinkText = color "blue";
        markdownListEnumeration = color "peach";
        markdownListItem = color "blue";
        markdownStrong = color "yellow";
        markdownText = color "text";
        syntaxComment = color "overlay1";
        syntaxFunction = color "blue";
        syntaxKeyword = color "mauve";
        syntaxNumber = color "peach";
        syntaxOperator = color "sky";
        syntaxPunctuation = color "subtext0";
        syntaxString = color "green";
        syntaxType = color "yellow";
        syntaxVariable = color "pink";
      };
    };
  };

  xdg.configFile = {
    "opencode/plugins/i-have-adhd.mjs".source =
      "${inputs.i-have-adhd}/.opencode/plugins/i-have-adhd.mjs";
    "opencode/plugins/i-have-adhd.js".source = "${inputs.i-have-adhd}/.opencode/plugins/i-have-adhd.js";
    "opencode/command/i-have-adhd.md".source = "${inputs.i-have-adhd}/.opencode/command/i-have-adhd.md";
  };

  home.file = {
    ".config/skills/i-have-adhd/SKILL.md".source = "${inputs.i-have-adhd}/skills/i-have-adhd/SKILL.md";
  };
}
