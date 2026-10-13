#!/usr/bin/env bash
set -euo pipefail

if rg -n 'pkgs\.(runCommand|stdenv\.mkDerivation)|builtins\.readDir|lib\.(mapAttrsToList|filterAttrs|concatMapStringsSep)' home-manager --glob '*.nix'; then
  printf 'Home Manager modules must contain settings, not generation logic\n' >&2
  exit 1
fi

expected='{"homeUsesChezmoi":false,"unusedInputsAbsent":true}'
actual="$(nix eval --impure --json --expr '
  let
    flake = builtins.getFlake ("path:" + toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
    home = flake.homeConfigurations.earlgray;
    packagePaths = map (package: package.drvPath) home.config.home.packages;
  in {
    homeUsesChezmoi = builtins.elem pkgs.chezmoi.drvPath packagePaths;
    unusedInputsAbsent = builtins.all (name: !(builtins.hasAttr name flake.inputs)) [
      "_1password-shell-plugins"
      "rust-overlay"
      "ghostty"
      "tree-sitter"
    ];
  }
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected Home Manager boundaries: %s\n' "$actual" >&2
  exit 1
fi
