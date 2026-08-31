#!/usr/bin/env bash

set -euo pipefail

expected='{"claude":"caveman","claudeHook":true,"claudeSkill":true,"codex":"caveman","codexSkill":true,"version":"0.1.0"}'
actual="$(nix eval --impure --raw --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
    extensions = import ./home-manager/ai-extensions.nix {
      inherit pkgs;
      claude-plugins-official = flake.inputs.claude-plugins-official;
      superpowers-skills = flake.inputs.superpowers-skills;
      google-skills = flake.inputs.google-skills;
      github-skills = flake.inputs.github-skills;
      ponytail = flake.inputs.ponytail;
      go-modern-guidelines = flake.inputs.go-modern-guidelines;
      caveman = flake.inputs.caveman;
    };
    claudeSource = extensions.claudePlugins.caveman;
    isCaveman = source:
      (builtins.fromJSON (builtins.readFile (source + "/.codex-plugin/plugin.json"))).name == "caveman";
    codexSource = builtins.head (builtins.filter isCaveman extensions.codexPlugins);
    claudeManifest = builtins.fromJSON (builtins.readFile (claudeSource + "/.claude-plugin/plugin.json"));
    codexManifest = builtins.fromJSON (builtins.readFile (codexSource + "/.codex-plugin/plugin.json"));
  in
    builtins.toJSON {
      claude = claudeManifest.name;
      codex = codexManifest.name;
      version = codexManifest.version;
      claudeHook = builtins.pathExists (claudeSource + "/src/hooks/caveman-activate.js");
      claudeSkill = builtins.pathExists (claudeSource + "/skills/caveman/SKILL.md");
      codexSkill = builtins.pathExists (codexSource + "/skills/caveman/SKILL.md");
    }
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected Caveman plugin integration: %s\n' "$actual" >&2
  exit 1
fi
