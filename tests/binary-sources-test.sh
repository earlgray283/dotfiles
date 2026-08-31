#!/usr/bin/env bash
set -euo pipefail

expected='{"codexManaged":true,"codexRelease":true,"numtideDisabled":true,"opencodeManaged":true,"opencodeRelease":true}'
actual="$(nix eval --impure --json --expr '
  let
    flake = builtins.getFlake (toString ./.);
    system = "aarch64-darwin";
    lib = flake.inputs.nixpkgs.lib;
    home = flake.homeConfigurations.earlgray.config;
    darwin = flake.darwinConfigurations.makabeee-macbook-pro.config;
    codex = flake.packages.${system}.codex or null;
    opencode = flake.packages.${system}.opencode or null;
    releaseUrl = package: builtins.head package.src.urls;
  in {
    codexManaged = codex != null && home.programs.codex.package.drvPath == codex.drvPath;
    codexRelease = lib.hasPrefix "https://github.com/openai/codex/releases/download/" (releaseUrl home.programs.codex.package);
    opencodeManaged = opencode != null && home.programs.opencode.package.drvPath == opencode.drvPath;
    opencodeRelease = lib.hasPrefix "https://github.com/anomalyco/opencode/releases/download/" (releaseUrl home.programs.opencode.package);
    numtideDisabled = !(builtins.elem "https://cache.numtide.com" darwin.nix.settings.trusted-substituters);
  }
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected binary sources: %s\n' "$actual" >&2
  exit 1
fi
