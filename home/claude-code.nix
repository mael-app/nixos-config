{ inputs, pkgs, ... }:

{
  # Claude Code itself is installed from packages.nix; this module only adds
  # declarative MCP servers. With no `settings`, Home Manager leaves the
  # user-managed ~/.claude/settings.json (RTK hook, plugins) untouched.
  programs.claude-code = {
    enable = true;
    package = null;

    # Only the skill directory: the upstream plugin also installs hooks
    # that log per-task costs and can post them to a webhook.
    skills.ponytail = "${inputs.ponytail}/skills/ponytail";

    # Browser automation through the nixpkgs Playwright MCP build. It ships
    # Playwright's patched Firefox at the matching version, which stock
    # Firefox cannot replace, and needs no npx download at runtime.
    mcpServers.playwright = {
      command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
      args = [
        "--browser"
        "firefox"
        "--headless"
      ];
    };
  };
}
