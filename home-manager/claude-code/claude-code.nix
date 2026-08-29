{
  lib,
  pkgs,
  config,
  claude-plugins-official,
  superpowers-skills,
  claude-mem,
  google-skills,
  ...
}:

let
  dotfilesDir = "${config.home.homeDirectory}/dev/dotfiles/home-manager/claude-code";
  aiExtensions = import ../ai-extensions.nix {
    inherit
      pkgs
      claude-plugins-official
      superpowers-skills
      claude-mem
      google-skills
      ;
  };
  herdrIntegrations = import ../herdr-integrations.nix { inherit pkgs; };
in
{
  programs.claude-code = {
    enable = true;

    package = pkgs.llm-agents.claude-code;

    enableMcpIntegration = true;

    marketplaces = {
      claude-plugins-official = claude-plugins-official;
      claude-mem = claude-mem;
    };

    plugins = aiExtensions.claudePlugins;

    skills = aiExtensions.skills;

    hooksDir = ./hooks;
  };

  home.file."${config.home.homeDirectory}/.claude/settings.json".enable = lib.mkForce false;

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/CLAUDE.md";

  home.file.".claude/hooks/herdr-agent-state.sh".source = herdrIntegrations.claudeHook;
}
