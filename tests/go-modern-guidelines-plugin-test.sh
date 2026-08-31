#!/usr/bin/env bash

set -euo pipefail

expected='{"claude":"modern-go-guidelines","codex":"modern-go-guidelines","script":true,"skill":true,"version":"1.1.1"}'
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
    };
    claudeSource = extensions.claudePlugins.modern-go-guidelines;
    isModernGo = source:
      (builtins.fromJSON (builtins.readFile (source + "/.codex-plugin/plugin.json"))).name
      == "modern-go-guidelines";
    codexSource = builtins.head (builtins.filter isModernGo extensions.codexPlugins);
    claudeManifest = builtins.fromJSON (builtins.readFile (claudeSource + "/.claude-plugin/plugin.json"));
    codexManifest = builtins.fromJSON (builtins.readFile (codexSource + "/.codex-plugin/plugin.json"));
  in
    builtins.toJSON {
      claude = claudeManifest.name;
      codex = codexManifest.name;
      version = codexManifest.version;
      skill = builtins.pathExists (codexSource + "/skills/use-modern-go/SKILL.md");
      script = builtins.pathExists (codexSource + "/skills/use-modern-go/scripts/run-tool.sh");
    }
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected Modern Go Guidelines plugin integration: %s\n' "$actual" >&2
  exit 1
fi
