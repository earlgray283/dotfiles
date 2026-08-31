{
  pkgs,
  superpowers-skills,
  google-skills,
  github-skills,
  ponytail,
  go-modern-guidelines,
  caveman,
  openai-plugins,
  ...
}:

let
  aiExtensions = import ./ai-extensions.nix {
    inherit
      pkgs
      superpowers-skills
      google-skills
      github-skills
      ponytail
      go-modern-guidelines
      caveman
      openai-plugins
      ;
  };
  herdrIntegrations = import ./herdr-integrations.nix { inherit pkgs; };
in
{
  programs.codex = {
    enable = true;

    package = (import ../packages { inherit pkgs; }).codex;

    enableMcpIntegration = true;

    skills = aiExtensions.codexSkills;

    plugins = aiExtensions.codexPlugins;

    settings = {
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      model = "gpt-5.6-sol";
      model_provider = "openai";
      model_reasoning_effort = "medium";
      plan_mode_reasoning_effort = "medium";
      service_tier = "default";
      web_search = "live";
      features.hooks = true;
      hooks.state = {
        "/Users/earlgray/.codex/hooks.json:session_start:0:0".trusted_hash =
          "sha256:cdb45465c937a59b479d2e100e37d477d6c5884cc718fd2c4d65b4a6570f3d7a";
        "ponytail@home-manager:hooks/claude-codex-hooks.json:session_start:0:0".trusted_hash =
          "sha256:5f81d38f47448a1581c08ec877e044d9e04dd6f814dce3f2671f7a8edadd719b";
        "ponytail@home-manager:hooks/claude-codex-hooks.json:subagent_start:0:0".trusted_hash =
          "sha256:1423b56c1322f96c8f74c51c1e7ae9a047b904c1fa43ee9165d462fd7a6e70ef";
        "ponytail@home-manager:hooks/claude-codex-hooks.json:user_prompt_submit:0:0".trusted_hash =
          "sha256:6a6f42bc3b58d6262db38bfd74d7f340fcca2b09cdb134aad365063f0bfefca4";
      };
      projects."/Users/earlgray/dev/dotfiles".trust_level = "trusted";
    };

    context = ./claude-code/CLAUDE.md;

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

  home.file.".codex/herdr-agent-state.sh".source = herdrIntegrations.codexHook;
}
