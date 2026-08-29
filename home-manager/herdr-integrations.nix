{ pkgs }:

# `herdr integration install <agent>` writes into ~/.claude/settings.json,
# ~/.codex/config.toml and friends, which are read-only home-manager symlinks.
# The hook payloads are plain assets in herdr's own source tree, so take them
# from the same revision the binary is built from and wire them up declaratively.
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
