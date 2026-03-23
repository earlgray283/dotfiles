{
  lib,
  agent-skills,
  anthropic-skills,
  claude-code-guide-skills,
  superpowers-skills,
  claude-plugins-official,
  ...
}:
{
  imports = [
    (import "${agent-skills.outPath}/modules/home-manager/agent-skills.nix" {
      inherit lib;
      inputs = { };
    })
  ];

  programs.agent-skills = {
    enable = true;
    sources = {
      anthropic = {
        path = anthropic-skills;
        subdir = "skills";
      };
      claude-code-guide = {
        path = claude-code-guide-skills;
        subdir = "skills";
      };
      superpowers = {
        path = superpowers-skills;
        subdir = "skills";
      };
      claude-md-management = {
        path = claude-plugins-official;
        subdir = "plugins/claude-md-management/skills";
      };
    };
    skills.enable = [
      "brainstorming"
      "claude-api"
      "dispatching-parallel-agents"
      "executing-plans"
      "finishing-a-development-branch"
      "frontend-design"
      "pdf"
      "receiving-code-review"
      "requesting-code-review"
      "skill-creator"
      "subagent-driven-development"
      "systematic-debugging"
      "test-driven-development"
      "using-git-worktrees"
      "using-superpowers"
      "verification-before-completion"
      "writing-plans"
      "writing-skills"
    ];
    targets = {
      codex = {
        dest = ".codex/skills";
        structure = "copy-tree";
      };
      claude = {
        dest = ".claude/skills";
        structure = "copy-tree";
      };
    };
  };
}
