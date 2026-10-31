{ pkgs, ... }:

let
  herdrIntegrations = import ../lib/herdr-integrations.nix { inherit pkgs; };
in
{
  programs.opencode = {
    enable = true;

    package = null;

    enableMcpIntegration = true;

    context = ./ai/instructions.md;

    settings = {
      autoupdate = false;
      # OpenCode's last matching rule wins.
      permission = {
        bash = {
          "bun *" = "allow";
          "cargo *" = "allow";
          "fd *" = "allow";
          "git add *" = "allow";
          "git commit *" = "allow";
          "git diff *" = "allow";
          "go *" = "allow";
          "home-manager build *" = "allow";
          "home-manager switch *" = "allow";
          "just *" = "allow";
          "ls *" = "allow";
          "mkdir *" = "allow";
          "nix eval *" = "allow";
          "rg *" = "allow";
          "rm *" = "deny";
          "find *" = "deny";
          "grep *" = "deny";
        };
        read = {
          ".env" = "deny";
          "credentials.json" = "deny";
        };
        edit = {
          ".env" = "deny";
          "credentials.json" = "deny";
        };
        playwright_browser_evaluate = "allow";
        playwright_browser_navigate = "allow";
        playwright_browser_resize = "allow";
        playwright_browser_take_screenshot = "allow";
      };
      plugin = [
        "superpowers@git+https://github.com/obra/superpowers.git"
      ];
    };
  };

  home.file.".config/opencode/plugins/herdr-agent-state.js".source = herdrIntegrations.opencodePlugin;
}
