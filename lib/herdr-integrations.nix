{ pkgs }:

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
