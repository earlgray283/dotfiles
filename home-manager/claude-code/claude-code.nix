{
  lib,
  pkgs,
  config,
  claude-plugins-official,
  superpowers-skills,
  claude-mem,
  google-skills,
  ponytail,
  go-modern-guidelines,
  caveman,
  ...
}:

let
  dotfilesDir = "${config.home.homeDirectory}/dev/dotfiles/home-manager/claude-code";
  jsonFormat = pkgs.formats.json { };
  claudeSettings = {
    env = {
      CLAUDE_CODE_NO_FLICKER = "1";
      DISABLE_AUTOUPDATER = "1";
    };
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
    hooks = {
      Notification = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "bun ~/.claude/hooks/notifications/Notification.ts";
            }
          ];
        }
      ];
      PermissionRequest = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "bun ~/.claude/hooks/notifications/PermissionRequest.ts";
            }
          ];
        }
      ];
      SessionStart = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "bash ~/.claude/hooks/herdr-agent-state.sh session";
              timeout = 10;
            }
          ];
        }
      ];
      Stop = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "bun ~/.claude/hooks/notifications/Stop.ts";
            }
          ];
        }
      ];
    };
    sandbox = {
      enabled = false;
      autoAllowBashIfSandboxed = true;
      enableWeakerNetworkIsolation = true;
    };
  };
  aiExtensions = import ../ai-extensions.nix {
    inherit
      pkgs
      claude-plugins-official
      superpowers-skills
      claude-mem
      google-skills
      ponytail
      go-modern-guidelines
      caveman
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
      inherit ponytail;
      inherit go-modern-guidelines;
      inherit caveman;
    };

    plugins = aiExtensions.claudePlugins;

    skills = aiExtensions.skills;

    hooksDir = ./hooks;
  };

  home.file."${config.home.homeDirectory}/.claude/settings.json".enable = lib.mkForce false;

  home.file."dev/dotfiles/chezmoi/.chezmoitemplates/nix/claude-settings.json".source =
    jsonFormat.generate "claude-settings.json" claudeSettings;

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/CLAUDE.md";

  home.file.".claude/hooks/herdr-agent-state.sh".source = herdrIntegrations.claudeHook;
}
