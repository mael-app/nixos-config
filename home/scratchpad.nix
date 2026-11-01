{
  config,
  lib,
  pkgs,
  ...
}:

# Dropdown scratchpads (SUPER + S terminal, SUPER + SHIFT + S btop). The
# window rules in hyprland.nix park these windows on special workspaces;
# this script spawns the app when it is not running yet and toggles the
# workspace afterwards, so no daemon keeps them alive in between.
let
  cfg = config.local.scratchpad;
in
{
  options.local.scratchpad = {
    command = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "The command that toggles a scratchpad (term or btop).";
    };
  };

  config = {
    local.scratchpad.command =
      let
        script = pkgs.writeShellApplication {
          name = "scratchpad";
          runtimeInputs = with pkgs; [
            hyprland
            jq
            ghostty
          ];
          text = ''
            case "''${1:-}" in
              term)
                class="com.mitchellh.ghostty.scratch"
                workspace="scratch"
                cmd=(ghostty --class="$class")
                ;;
              btop)
                class="com.mitchellh.ghostty.btop-scratch"
                workspace="btop"
                cmd=(ghostty --class="$class" -e btop)
                ;;
              *)
                echo "usage: scratchpad {term|btop}" >&2
                exit 1
                ;;
            esac

            open() {
              hyprctl clients -j | jq -e --arg c "$class" \
                '.[] | select(.class == $c)' > /dev/null
            }

            if ! open; then
              "''${cmd[@]}" &
              # Show the workspace only once the window has landed on it.
              for _ in $(seq 1 50); do
                open && break
                sleep 0.1
              done
            fi
            hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$workspace\")"
          '';
        };
      in
      "${script}/bin/scratchpad";
  };
}
