{ pkgs }:

# The final Claude and Codex settings are mutable, but hook payloads remain
# declarative assets from the same herdr revision as the installed binary.
#
# Copied out rather than symlinked in place: linking straight into
# `pkgs.herdr.src` would pin its 33 MiB closure into the profile for three
# small scripts.
let
  assets =
    pkgs.runCommand "herdr-integration-assets"
      {
        src = pkgs.herdr.src;
      }
      ''
        for asset in claude/herdr-agent-state.sh codex/herdr-agent-state.sh opencode/herdr-agent-state.js; do
          install -Dm444 "$src/src/integration/assets/$asset" "$out/$asset"
        done
      '';
in
{
  claudeHook = "${assets}/claude/herdr-agent-state.sh";
  codexHook = "${assets}/codex/herdr-agent-state.sh";
  opencodePlugin = "${assets}/opencode/herdr-agent-state.js";
}
