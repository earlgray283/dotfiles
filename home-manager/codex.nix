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
  dotfilesDir = "${config.home.homeDirectory}/dev/dotfiles/home-manager/claude-code";
  aiExtensions = import ./ai-extensions.nix {
    inherit
      pkgs
      claude-plugins-official
      superpowers-skills
      claude-mem
      google-skills
      ;
  };
  herdrIntegrations = import ./herdr-integrations.nix { inherit pkgs; };
in
{
  programs.codex = {
    enable = true;

    package = pkgs.llm-agents.codex;

    enableMcpIntegration = true;

    plugins = aiExtensions.codexPlugins;

    skills = aiExtensions.skills;

    settings = {
      model = "gpt-5.6-sol";
      model_provider = "openai";
      model_reasoning_effort = "high";
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";

      # Required for ~/.codex/hooks.json to be read at all.
      features.hooks = true;

      projects."/Users/earlgray/dev/dotfiles".trust_level = "trusted";
    };
  };

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
