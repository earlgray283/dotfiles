{ pkgs, ... }:

let
  herdrIntegrations = import ./herdr-integrations.nix { inherit pkgs; };
in
{
  programs.opencode = {
    enable = true;

    package = (import ../packages { inherit pkgs; }).opencode;

    enableMcpIntegration = true;

    context = ./claude-code/CLAUDE.md;

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
                command = "bun ~/.config/opencode/hooks/notifications/Stop.ts";
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
                command = "bun ~/.config/opencode/hooks/notifications/Notification.ts";
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
                command = "bun ~/.config/opencode/hooks/notifications/PermissionRequest.ts";
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
          "mcp__playwright__browser_evaluate:*"
          "mcp__playwright__browser_navigate:*"
          "mcp__playwright__browser_resize:*"
          "mcp__playwright__browser_take_screenshot:*"
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
      plugin = [
        "superpowers@git+https://github.com/obra/superpowers.git"
      ];
    };
  };

  # hooks ディレクトリを home-manager で管理
  home.file.".config/opencode/hooks" = {
    source = ./claude-code/hooks;
    recursive = true;
  };

  home.file.".config/opencode/plugins/herdr-agent-state.js".source = herdrIntegrations.opencodePlugin;
}
