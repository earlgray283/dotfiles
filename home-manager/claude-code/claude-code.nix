{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;

    package = pkgs.claude-code.override { };

    enableMcpIntegration = true;

    memory.source = ./CLAUDE.md;

    hooksDir = ./hooks;

    skills = {
      commit = ./skills/commit;
    };

    mcpServers = {
      fetch = {
        type = "stdio";
        command = "uvx";
        args = [ "mcp-server-fetch" ];
      };
      sequential-thinking = {
        type = "stdio";
        command = "bunx";
        args = [ "@modelcontextprotocol/server-sequential-thinking" ];
      };
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp/oauth";
      };
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
      model = "sonnet";
      permissions = {
        allow = [
          "Bash(bun:*)"
          "Bash(cargo:*)"
          "Bash(fd:*)"
          "Bash(git add:*)"
          "Bash(git commit:*)"
          "Bash(git diff:*)"
          "Bash(go:*)"
          "Bash(just:*)"
          "Bash(ls:*)"
          "Bash(mkdir:*)"
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
