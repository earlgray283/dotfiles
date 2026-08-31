#!/usr/bin/env bash
set -euo pipefail

expected='{"claudeKept":[true,true,true,true,true,true,true,true,true],"claudeRemoved":[true,true,true,true],"claudeSkills":[true,true,true,true],"codexRemoved":[true,true,true,true],"codexSkills":[true,true,true,true,true,true,true,true,true,true,true],"inputs":[true,true,true]}'
actual="$(nix eval --impure --raw --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
    extensions = import ./home-manager/ai-extensions.nix {
      inherit pkgs;
      claude-plugins-official = flake.inputs.claude-plugins-official;
      anthropic-skills = flake.inputs.anthropic-skills;
      superpowers-skills = flake.inputs.superpowers-skills;
      google-skills = flake.inputs.google-skills;
      github-skills = flake.inputs.github-skills;
      openai-plugins = flake.inputs.openai-plugins;
    };
    codexSkillNames = [
      "git-commit"
      "github-issues"
      "github-release"
      "premium-frontend-ui"
      "security-review"
      "refactor"
      "breakdown-feature-implementation"
      "cloud-run-basics"
      "firebase-basics"
      "gke-basics"
      "spanner-basics"
    ];
    claudeSkillNames = [
      "academy-guide"
      "mcp-builder"
      "gke-basics"
      "spanner-basics"
    ];
    codexRemovedNames = [
      "academy-guide"
      "bigquery-basics"
      "figma-use"
      "security-best-practices"
    ];
    claudeKept = [
      "claude-code-setup"
      "claude-md-management"
      "commit-commands"
      "gopls-lsp"
      "rust-analyzer-lsp"
      "skill-creator"
      "superpowers"
      "code-simplifier"
      "security-guidance"
    ];
    claudeRemoved = [
      "code-review"
      "feature-dev"
      "ralph-loop"
      "claude-mem"
    ];
  in
    builtins.toJSON {
      claudeKept = map (name: builtins.hasAttr name extensions.claudePlugins) claudeKept;
      claudeRemoved = map (name: !(builtins.hasAttr name extensions.claudePlugins)) claudeRemoved;
      claudeSkills = map (name: builtins.pathExists ((builtins.getAttr name extensions.claudeSkills) + "/SKILL.md")) claudeSkillNames;
      codexSkills = map (name: builtins.pathExists ((builtins.getAttr name extensions.codexSkills) + "/SKILL.md")) codexSkillNames;
      codexRemoved = map (name: !(builtins.hasAttr name extensions.codexSkills)) codexRemovedNames;
      inputs = [
        (builtins.hasAttr "openai-plugins" flake.inputs)
        (!(builtins.hasAttr "openai-skills" flake.inputs))
        (!(builtins.hasAttr "claude-code-guide-skills" flake.inputs))
      ];
    }
')"

if [[ "$actual" != "$expected" ]]; then
  printf 'unexpected Codex Skill set: %s\n' "$actual" >&2
  exit 1
fi
