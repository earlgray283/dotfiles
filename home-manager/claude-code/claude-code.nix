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

    settings = {
      model = "claude-opus-5";
      effortLevel = "high";
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
        SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "bash ~/.claude/hooks/herdr-agent-state.sh session";
                timeout = 10;
              }
            ];
            matcher = "*";
          }
        ];
      };
      includeCoAuthoredBy = true;
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

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/CLAUDE.md";

  home.file.".claude/hooks/herdr-agent-state.sh".source = herdrIntegrations.claudeHook;
}
