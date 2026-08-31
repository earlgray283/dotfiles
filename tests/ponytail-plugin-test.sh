#!/usr/bin/env bash

set -euo pipefail

expected='{"claude":"ponytail","codex":"ponytail","hooks":true,"skill":true}'
actual="$(nix eval --impure --raw --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
    extensions = import ./lib/ai-extensions.nix {
      inherit (pkgs) lib;
      config = import ./home-manager/ai-extensions.nix;
      sources = {
        claudePluginsOfficial = flake.inputs.claude-plugins-official;
        superpowersSkills = flake.inputs.superpowers-skills;
        googleSkills = flake.inputs.google-skills;
        githubSkills = flake.inputs.github-skills;
        ponytail = flake.inputs.ponytail;
      };
    };
    claudeSource = extensions.claudePlugins.ponytail;
    codexSource = builtins.head extensions.codexPlugins;
    claudeManifest = builtins.fromJSON (builtins.readFile (claudeSource + "/.claude-plugin/plugin.json"));
    codexManifest = builtins.fromJSON (builtins.readFile (codexSource + "/.codex-plugin/plugin.json"));
  in
    builtins.toJSON {
      claude = claudeManifest.name;
      codex = codexManifest.name;
      hooks = builtins.pathExists (codexSource + "/hooks/claude-codex-hooks.json");
      skill = builtins.pathExists (codexSource + "/skills/ponytail/SKILL.md");
    }
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected Ponytail plugin integration: %s\n' "$actual" >&2
  exit 1
fi
