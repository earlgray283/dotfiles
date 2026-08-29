{
  pkgs,
  claude-plugins-official,
  superpowers-skills,
  claude-mem,
  google-skills,
}:

let
  inherit (pkgs) lib;

  wrappedPlugins = {
    frontend-design = claude-plugins-official + "/plugins/frontend-design";
    code-review = claude-plugins-official + "/plugins/code-review";
    code-simplifier = claude-plugins-official + "/plugins/code-simplifier";
    skill-creator = claude-plugins-official + "/plugins/skill-creator";
    feature-dev = claude-plugins-official + "/plugins/feature-dev";
    claude-md-management = claude-plugins-official + "/plugins/claude-md-management";
    ralph-loop = claude-plugins-official + "/plugins/ralph-loop";
    security-guidance = claude-plugins-official + "/plugins/security-guidance";
    commit-commands = claude-plugins-official + "/plugins/commit-commands";
    claude-code-setup = claude-plugins-official + "/plugins/claude-code-setup";
    gopls-lsp = claude-plugins-official + "/plugins/gopls-lsp";
    rust-analyzer-lsp = claude-plugins-official + "/plugins/rust-analyzer-lsp";
    context7 = claude-plugins-official + "/external_plugins/context7";
  };

  nativePlugins = {
    superpowers = superpowers-skills;
    claude-mem = claude-mem;
  };

  mkCodexPlugin =
    name: source:
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
        pname = name;
      }
      ''
        install -Dm644 ${pkgs.writeText "plugin.json" (builtins.toJSON manifest)} "$out/.codex-plugin/plugin.json"
        ${lib.optionalString hasSkills ''ln -s ${source}/skills "$out/skills"''}
      '';
in
{
  claudePlugins = wrappedPlugins // nativePlugins;
  codexPlugins = lib.mapAttrsToList mkCodexPlugin wrappedPlugins ++ lib.attrValues nativePlugins;
  skills = "${google-skills}/skills/cloud";
}
