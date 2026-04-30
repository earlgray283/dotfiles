{ inputs, pkgs, claude-plugins-official, superpowers-skills, ... }:

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

    skills = {
      commit = ./skills/commit;
    };

    settings = {
      env = {
        DISABLE_AUTOUPDATER = "1";
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
          "Bash(bun:*)"
          "Bash(cargo:*)"
          "Bash(fd:*)"
          "Bash(git add:*)"
          "Bash(git commit:*)"
          "Bash(git diff:*)"
          "Bash(go:*)"
          "Bash(home-manager build:*)"
          "Bash(home-manager switch:*)"
          "Bash(just:*)"
          "Bash(ls:*)"
          "Bash(mkdir:*)"
          "Bash(nix eval:*)"
          "Bash(rg:*)"
          "mcp__context7__get-library-docs"
          "mcp__context7__resolve-library-id"
          "mcp__playwright__browser_evaluate:*"
          "mcp__playwright__browser_navigate:*"
          "mcp__playwright__browser_resize:*"
          "mcp__playwright__browser_take_screenshot:*"
          "mcp__serena__check_onboarding_performed"
          "mcp__serena__find_file"
          "mcp__serena__find_symbol"
          "mcp__serena__get_symbols_overview"
          "mcp__serena__list_dir"
          "mcp__serena__onboarding"
          "mcp__serena__replace_symbol_body"
          "mcp__serena__search_for_pattern"
          "mcp__serena__think_about_collected_information"
          "mcp__serena__think_about_whether_you_are_done"
          "mcp__serena__write_memory"
        ];
        deny = [
          "Bash(rm:*)"
          "Read(.env)"
          "Read(credentials.json)"
          "Write(.env)"
          "Write(credentials.json)"
          "Bash(find:*)"
          "Bash(grep:*)"
        ];
      };
    };
  };
}
