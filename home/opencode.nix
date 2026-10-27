{ inputs, ... }:

{
  xdg.configFile = {
    "opencode/plugins/i-have-adhd.mjs".source =
      "${inputs.i-have-adhd}/.opencode/plugins/i-have-adhd.mjs";
    "opencode/plugins/i-have-adhd.js".source =
      "${inputs.i-have-adhd}/.opencode/plugins/i-have-adhd.js";
    "opencode/command/i-have-adhd.md".source =
      "${inputs.i-have-adhd}/.opencode/command/i-have-adhd.md";
  };

  home.file = {
    ".config/skills/i-have-adhd/SKILL.md".source =
      "${inputs.i-have-adhd}/skills/i-have-adhd/SKILL.md";
  };
}
