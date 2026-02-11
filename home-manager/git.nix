{ pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    ignores = [
      "**/.claude/settings.local.json"
      ".claude"
      "CLAUDE.md"
      ".mc.json"
      "AGENTS.md"
      ".serena"
      ".mcp.json"
      ".zed"
      ".vscode"
      ".DS_Store"
    ];
    settings = {
      user = {
        name = "earlgray";
        email = "earlgray283@gmail.com";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0VEO5o1ZowITdzAIUqUbAO7zVA2QKrDHkmPFsvtPnV";
      };
      commit = {
        gpgSign = true;
      };
      tag = {
        gpgSign = true;
      };
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      core = {
        pager = "delta";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      delta = {
        navigate = true;
        light = false;
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
      alias = {
        lo = "log --oneline";
      };
      push = {
        autoSetupRemote = true;
      };
      init = {
        defaultBranch = "main";
      };
      url."ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
    };
  };
}
