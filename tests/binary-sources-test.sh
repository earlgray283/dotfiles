#!/usr/bin/env bash
set -euo pipefail

expected='{"claudeExternal":true,"codexExternal":true,"gitMinimal":true,"numtideDisabled":true,"opencodeExternal":true}'
actual="$(nix eval --impure --json --expr '
  let
    flake = builtins.getFlake ("path:" + toString ./.);
    system = "aarch64-darwin";
    pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
    home = flake.homeConfigurations.earlgray.config;
    darwin = flake.darwinConfigurations.makabeee-macbook-pro.config;
  in {
    claudeExternal = home.programs.claude-code.package == null;
    codexExternal = home.programs.codex.package == null;
    gitMinimal = home.programs.git.package.drvPath == pkgs.gitMinimal.drvPath;
    opencodeExternal = home.programs.opencode.package == null;
    numtideDisabled = !(builtins.elem "https://cache.numtide.com" darwin.nix.settings.trusted-substituters);
  }
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected binary sources: %s\n' "$actual" >&2
  exit 1
fi

claude_installer="$(nix build --no-link --print-out-paths path:.#claude-code-installer)"
codex_installer="$(nix build --no-link --print-out-paths path:.#codex-installer)"

if nix path-info -r "$claude_installer" "$codex_installer" | rg -q -- '-(claude-code|codex)-installer\.sh$'; then
  echo 'vendor installer scripts must not be pinned in the Nix store' >&2
  exit 1
fi

codex_help="$("$codex_installer/bin/codex-installer" --help)"
test "${codex_help%%$'\n'*}" = 'Usage: install.sh [--release VERSION]'

if claude_usage="$("$claude_installer/bin/claude-code-installer" --not-a-target 2>&1)"; then
  echo 'Claude installer accepted an invalid target' >&2
  exit 1
fi
[[ "$claude_usage" == *'[stable|latest|VERSION]'* ]]

claude_update_recipe=$(just --show update-claude-code)
codex_update_recipe=$(just --show update-codex)
ai_update_recipe=$(just --show update-ai)

[[ "$claude_update_recipe" == *'claude update'* ]]
[[ "$codex_update_recipe" == *'codex update'* ]]
[[ "$ai_update_recipe" == *'update-claude-code update-codex'* ]]
