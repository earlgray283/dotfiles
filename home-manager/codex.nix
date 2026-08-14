{
  pkgs,
  config,
  claude-plugins-official,
  superpowers-skills,
  claude-mem,
  google-skills,
  ...
}:

let
  inherit (pkgs) lib;
  dotfilesDir = "${config.home.homeDirectory}/dev/dotfiles/home-manager/claude-code";

  # claude-plugins-official plugins don't have .codex-plugin/plugin.json,
  # so wrap them with a generated manifest that exposes their skills directory.
  mkCodexPlugin =
    { name, source }:
    let
      hasSkills = builtins.pathExists (source + "/skills");
      manifest = {
        inherit name;
        version = "0.0.0";
        description = "Codex wrapper for ${name}.";
        author.name = "Home Manager";
        interface = {
          displayName = name;
          shortDescription = "Managed by Home Manager.";
          developerName = "Home Manager";
          category = "Productivity";
        };
      }
      // lib.optionalAttrs hasSkills { skills = "./skills"; };
    in
    pkgs.runCommand "codex-plugin-${name}"
      {
        # pname is used by programs.codex.plugins to derive the plugin name
        pname = name;
      }
      ''
        install -Dm644 ${pkgs.writeText "plugin.json" (builtins.toJSON manifest)} "$out/.codex-plugin/plugin.json"
        ${lib.optionalString hasSkills ''ln -s ${source}/skills "$out/skills"''}
      '';
in
{
  programs.codex = {
    enable = true;

    package = pkgs.llm-agents.codex;

    enableMcpIntegration = true;

    plugins = [
      (mkCodexPlugin {
        name = "frontend-design";
        source = claude-plugins-official + "/plugins/frontend-design";
      })
      (mkCodexPlugin {
        name = "code-review";
        source = claude-plugins-official + "/plugins/code-review";
      })
      (mkCodexPlugin {
        name = "code-simplifier";
        source = claude-plugins-official + "/plugins/code-simplifier";
      })
      (mkCodexPlugin {
        name = "skill-creator";
        source = claude-plugins-official + "/plugins/skill-creator";
      })
      (mkCodexPlugin {
        name = "feature-dev";
        source = claude-plugins-official + "/plugins/feature-dev";
      })
      (mkCodexPlugin {
        name = "claude-md-management";
        source = claude-plugins-official + "/plugins/claude-md-management";
      })
      (mkCodexPlugin {
        name = "ralph-loop";
        source = claude-plugins-official + "/plugins/ralph-loop";
      })
      (mkCodexPlugin {
        name = "security-guidance";
        source = claude-plugins-official + "/plugins/security-guidance";
      })
      (mkCodexPlugin {
        name = "commit-commands";
        source = claude-plugins-official + "/plugins/commit-commands";
      })
      (mkCodexPlugin {
        name = "claude-code-setup";
        source = claude-plugins-official + "/plugins/claude-code-setup";
      })
      (mkCodexPlugin {
        name = "gopls-lsp";
        source = claude-plugins-official + "/plugins/gopls-lsp";
      })
      (mkCodexPlugin {
        name = "rust-analyzer-lsp";
        source = claude-plugins-official + "/plugins/rust-analyzer-lsp";
      })
      (mkCodexPlugin {
        name = "context7";
        source = claude-plugins-official + "/external_plugins/context7";
      })
      (mkCodexPlugin {
        name = "serena";
        source = claude-plugins-official + "/external_plugins/serena";
      })
      # superpowers-skills and claude-mem already have .codex-plugin/plugin.json
      superpowers-skills
      claude-mem
    ];

    skills = "${google-skills}/skills/cloud";

    settings = {
      model = "gpt-5.6-sol";
      model_provider = "openai";
      model_reasoning_effort = "high";
      approval_policy = "on-request";
    };
  };

  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/CLAUDE.md";
}
