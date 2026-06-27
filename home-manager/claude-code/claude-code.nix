{
  pkgs,
  claude-plugins-official,
  superpowers-skills,
  claude-mem,
  google-skills,
  ...
}:

{
  programs.claude-code = {
    enable = true;

    package = pkgs.llm-agents.claude-code;

    enableMcpIntegration = true;

    context = ./CLAUDE.md;

    marketplaces = {
      claude-plugins-official = claude-plugins-official;
      claude-mem = claude-mem;
    };

    plugins = [
      "${claude-plugins-official}/plugins/frontend-design"
      "${claude-plugins-official}/plugins/code-review"
      "${claude-plugins-official}/plugins/code-simplifier"
      "${claude-plugins-official}/plugins/skill-creator"
      "${claude-plugins-official}/plugins/feature-dev"
      "${claude-plugins-official}/plugins/claude-md-management"
      "${claude-plugins-official}/plugins/ralph-loop"
      "${claude-plugins-official}/plugins/security-guidance"
      "${claude-plugins-official}/plugins/commit-commands"
      "${claude-plugins-official}/plugins/claude-code-setup"
      "${claude-plugins-official}/plugins/gopls-lsp"
      "${claude-plugins-official}/plugins/rust-analyzer-lsp"
      "${claude-plugins-official}/external_plugins/context7"
      "${claude-plugins-official}/external_plugins/serena"
      superpowers-skills
      claude-mem
    ];

    skills = "${google-skills}/skills/cloud";

    hooksDir = ./hooks;

    settings = {
      env = {
        DISABLE_AUTOUPDATER = "1";
        CLAUDE_CODE_NO_FLICKER = "1";
      };
      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "bun ~/.claude/hooks/notifications/Stop.ts";
              }
            ];
            matcher = "";
          }
        ];
        Notification = [
          {
            hooks = [
              {
                type = "command";
                command = "bun ~/.claude/hooks/notifications/Notification.ts";
              }
            ];
            matcher = "";
          }
        ];
        PermissionRequest = [
          {
            hooks = [
              {
                type = "command";
                command = "bun ~/.claude/hooks/notifications/PermissionRequest.ts";
              }
            ];
            matcher = "";
          }
        ];
      };
      includeCoAuthoredBy = true;
      effortLevel = "xhigh";
      permissions = {
        allow = [
          "Bash(bin2nix *)"
          "Bash(darwin-rebuild build *)"
          "Bash(fd *)"
          "Bash(gh api *)"
          "Bash(gh pr list *)"
          "Bash(gh pr view *)"
          "Bash(gh repo *)"
          "Bash(git add *)"
          "Bash(git branch *)"
          "Bash(git commit *)"
          "Bash(git diff *)"
          "Bash(git log *)"
          "Bash(git show *)"
          "Bash(git status)"
          "Bash(home-manager build *)"
          "Bash(jq *)"
          "Bash(ls *)"
          "Bash(mkdir *)"
          "Bash(rg *)"
          "Bash(tar *)"
          "Bash(which *)"
        ];
        deny = [
          "Bash(curl *)"
          "Read(.env)"
          "Read(credentials.json)"
          "Bash(find *)"
          "Bash(grep *)"
        ];
        ask = [
          "Bash(rm *)"
          "Bash(git rm *)"
          "Bash(git push *)"
          "Bash(gh pr create *)"
          "Bash(home-manager switch *)"
        ];
        defaultMode = "auto";
      };
      sandbox = {
        enabled = false;
        autoAllowBashIfSandboxed = true;
        enableWeakerNetworkIsolation = true;
      };
    };
  };
}
