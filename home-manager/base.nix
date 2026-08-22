{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./starship.nix
    ./ghostty.nix
    ./aerospace.nix
    ./gh.nix
    ./git.nix
    ./zsh.nix
    ./ssh.nix
    ./tmux.nix
    ./claude-code/claude-code.nix
    ./codex.nix
    ./opencode.nix
    ./mcp.nix
    ./mise.nix
    ./direnv.nix
    ./neovim
  ];

  # Allow unfree packages (e.g. terraform)
  nixpkgs.config.allowUnfree = true;

  # Enable overlays
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.shared-nixpkgs
    # Workaround: direnv test-fish hangs on macOS due to broken fish code signature
    # caused by a nix registerOutputs bug (NixOS/nixpkgs#507531, NixOS/nix#15638)
    (_final: prev: {
      direnv = prev.direnv.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  home.username = "earlgray";
  home.homeDirectory = "/Users/earlgray";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = [
    # Shell/Terminal Tools
    pkgs.eza
    pkgs.skim
    pkgs.tealdeer
    pkgs.google-cloud-sdk
    pkgs.cachix
    pkgs._1password-cli

    # Git Tools
    pkgs.pre-commit

    # Go
    pkgs.go
    pkgs.gopls
    (lib.lowPrio pkgs.gotools) # Go tools including goimports

    # Python

    # Lua
    pkgs.lua
    pkgs.lua-language-server
    pkgs.luarocks

    # JavaScript/TypeScript
    pkgs.nodejs
    pkgs.bun
    pkgs.typescript-language-server
    pkgs.tailwindcss-language-server
    pkgs.oxlint

    # nix
    pkgs.nixd # Nix Language Server
    pkgs.nixfmt
    pkgs.nixfmt-tree

    # YAML
    pkgs.yamlfmt
    pkgs.yaml-language-server

    # TOML

    # Markdown
    pkgs.markdown-oxide # Markdown LSP

    # Docker
    pkgs.docker-language-server
    pkgs.hadolint
    pkgs.dockerfmt
    # pkgs.cockroachdb            # Linux only - not available on macOS

    # Terraform
    pkgs.terraform
    pkgs.terraform-ls

    # Protocol Buffers

    # Linters/Formatters

    # DB/SQL
    pkgs.atlas
    pkgs.sqruff # SQL linter
    pkgs.sqlfluff # SQL formatter

    # C/C++
    pkgs.clang-tools # includes clang-format

    # CUE
    pkgs.cue

    pkgs.wget
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
