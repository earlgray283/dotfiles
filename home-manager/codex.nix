{
  lib,
  pkgs,
  config,
  superpowers-skills,
  claude-mem,
  google-skills,
  github-skills,
  ...
}:

let
  dotfilesDir = "${config.home.homeDirectory}/dev/dotfiles/home-manager/claude-code";
  aiExtensions = import ./ai-extensions.nix {
    inherit
      pkgs
      superpowers-skills
      claude-mem
      google-skills
      github-skills
      ;
  };
  herdrIntegrations = import ./herdr-integrations.nix { inherit pkgs; };
in
{
  programs.codex = {
    enable = true;

    package = pkgs.llm-agents.codex;

    skills = aiExtensions.codexSkills;
  };

  home.file.".codex/config.toml".enable = lib.mkForce false;

  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/CLAUDE.md";

  home.file.".codex/herdr-agent-state.sh".source = herdrIntegrations.codexHook;

  home.file.".codex/hooks.json".text = builtins.toJSON {
    hooks.SessionStart = [
      {
        hooks = [
          {
            type = "command";
            command = "bash ~/.codex/herdr-agent-state.sh session";
            timeout = 10;
          }
        ];
      }
    ];
  };
}
