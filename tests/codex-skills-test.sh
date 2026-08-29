#!/usr/bin/env bash
set -euo pipefail

expected='[true,true,true,true,true,true,true]'
actual="$(nix eval --impure --raw --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
    extensions = import ./home-manager/ai-extensions.nix {
      inherit pkgs;
      claude-plugins-official = flake.inputs.claude-plugins-official;
      superpowers-skills = flake.inputs.superpowers-skills;
      claude-mem = flake.inputs.claude-mem;
      google-skills = flake.inputs.google-skills;
      github-skills = flake.inputs.github-skills;
    };
    names = [
      "git-commit"
      "github-issues"
      "github-release"
      "premium-frontend-ui"
      "security-review"
      "refactor"
      "breakdown-feature-implementation"
    ];
  in
    builtins.toJSON (map (name: builtins.pathExists ((builtins.getAttr name extensions.codexSkills) + "/SKILL.md")) names)
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected Codex Skill set: %s\n' "$actual" >&2
  exit 1
fi
