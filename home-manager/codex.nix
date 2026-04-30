{
  inputs,
  pkgs,
  claude-plugins-official,
  superpowers-skills,
  ...
}:

let
  inherit (pkgs) lib;

  codexPlugins = [
    {
      name = "frontend-design";
      source = claude-plugins-official + "/plugins/frontend-design";
    }
    {
      name = "code-review";
      source = claude-plugins-official + "/plugins/code-review";
    }
    {
      name = "code-simplifier";
      source = claude-plugins-official + "/plugins/code-simplifier";
    }
    {
      name = "skill-creator";
      source = claude-plugins-official + "/plugins/skill-creator";
    }
    {
      name = "feature-dev";
      source = claude-plugins-official + "/plugins/feature-dev";
    }
    {
      name = "claude-md-management";
      source = claude-plugins-official + "/plugins/claude-md-management";
    }
    {
      name = "ralph-loop";
      source = claude-plugins-official + "/plugins/ralph-loop";
    }
    {
      name = "security-guidance";
      source = claude-plugins-official + "/plugins/security-guidance";
    }
    {
      name = "commit-commands";
      source = claude-plugins-official + "/plugins/commit-commands";
    }
    {
      name = "claude-code-setup";
      source = claude-plugins-official + "/plugins/claude-code-setup";
    }
    {
      name = "gopls-lsp";
      source = claude-plugins-official + "/plugins/gopls-lsp";
    }
    {
      name = "rust-analyzer-lsp";
      source = claude-plugins-official + "/plugins/rust-analyzer-lsp";
    }
    {
      name = "context7";
      source = claude-plugins-official + "/external_plugins/context7";
    }
    {
      name = "serena";
      source = claude-plugins-official + "/external_plugins/serena";
    }
    {
      name = "superpowers";
      source = superpowers-skills;
    }
  ];

  mkCodexPlugin =
    {
      name,
      source,
      category ? "Productivity",
    }:
    let
      hasSkills = builtins.pathExists (source + "/skills");
      hasMcpServers = builtins.pathExists (source + "/.mcp.json");
      manifest = {
        inherit name;
        version = "0.0.0";
        description = "Codex wrapper for ${name}.";
        author.name = "Home Manager";
        interface = {
          displayName = name;
          shortDescription = "Managed by Home Manager.";
          developerName = "Home Manager";
          inherit category;
        };
      }
      // lib.optionalAttrs hasSkills {
        skills = "./skills";
      }
      // lib.optionalAttrs hasMcpServers {
        mcpServers = "./.mcp.json";
      };
    in
    pkgs.runCommand "codex-plugin-${name}" { } ''
      install -Dm644 ${pkgs.writeText "plugin.json" (builtins.toJSON manifest)} "$out/.codex-plugin/plugin.json"
      ${lib.optionalString hasSkills ''ln -s ${source}/skills "$out/skills"''}
      ${lib.optionalString hasMcpServers ''ln -s ${source}/.mcp.json "$out/.mcp.json"''}
    '';

  marketplace = {
    name = "home-manager";
    interface.displayName = "Home Manager";
    plugins = map (plugin: {
      inherit (plugin) name;
      source = {
        source = "local";
        path = "./plugins/${plugin.name}";
      };
      policy = {
        installation = "AVAILABLE";
        authentication = "ON_INSTALL";
      };
      category = plugin.category or "Productivity";
    }) codexPlugins;
  };
in

{
  programs.codex = {
    enable = true;

    package = pkgs.llm-agents.codex;

    enableMcpIntegration = true;
  };

  home.file = {
    ".agents/plugins/marketplace.json".text = builtins.toJSON marketplace;
  }
  // lib.listToAttrs (
    map (plugin: {
      name = "plugins/${plugin.name}";
      value.source = mkCodexPlugin plugin;
    }) codexPlugins
  );
}
