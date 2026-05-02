{
  pkgs,
  claude-plugins-official,
  superpowers-skills,
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
    ];

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
      includeCoAuthoredBy = false;
      permissions = {
        allow = [

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
        ];
        defaultMode = "auto";
      };
      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = true;
        enableWeakerNetworkIsolation = true;
      };
    };
  };
}
