{
  pkgs,
  inputs,
  lib,
  config,
  localPackages,
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
    ./sheldon.nix
    ./ssh.nix
    ./tmux.nix
    ./claude-code/claude-code.nix
    ./opencode.nix
    ./mcp.nix
    ./direnv.nix
    ./neovim
  ];

  # Allow unfree packages (e.g. terraform)
  nixpkgs.config.allowUnfree = true;

  # Enable overlays
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.default
    # Workaround: direnv test-fish hangs on macOS due to broken fish code signature
    # caused by a nix registerOutputs bug (NixOS/nixpkgs#507531, NixOS/nix#15638)
    (final: prev: {
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
    localPackages.fd
    localPackages.bat
    localPackages.ripgrep
    pkgs.eza
    localPackages.delta
    localPackages.fzf
    pkgs.skim
    pkgs.tealdeer
    localPackages.xh
    localPackages.television
    localPackages.just
    pkgs.google-cloud-sdk
    pkgs.cachix
    localPackages.tree-sitter
    pkgs._1password-cli

    # Git Tools
    localPackages.lazygit
    localPackages.gitleaks
    pkgs.pre-commit

    # Go
    pkgs.go
    pkgs.gopls
    (lib.lowPrio pkgs.gotools) # Go tools including goimports
    localPackages.golangci-lint

    # Python
    localPackages.uv

    # Lua
    pkgs.lua
    pkgs.lua-language-server
    localPackages.StyLua
    pkgs.luarocks

    # JavaScript/TypeScript
    pkgs.nodejs
    pkgs.bun
    pkgs.typescript-language-server
    pkgs.tailwindcss-language-server
    pkgs.oxlint
    localPackages.biome
    localPackages.dprint

    # nix
    pkgs.nixd # Nix Language Server
    pkgs.nixfmt
    pkgs.nixfmt-tree

    # YAML
    pkgs.yamlfmt
    pkgs.yaml-language-server
    localPackages.actionlint

    # TOML
    localPackages.taplo # TOML toolkit

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
    localPackages.buf
    localPackages.protolint

    # Linters/Formatters
    localPackages.vale # Prose linter

    # DB/SQL
    pkgs.atlas
    pkgs.sqruff # SQL linter
    pkgs.sqlfluff # SQL formatter

    # C/C++
    pkgs.clang-tools # includes clang-format

    # CUE
    pkgs.cue

    localPackages.hyperfine
    localPackages.mise
    localPackages.aqua
    pkgs.wget
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.activation.checkHostname = lib.hm.dag.entryBefore [ "checkFilesChanged" ] ''
    expected="earlgray@makabeee-macbook-air"
    actual="$(whoami)@$(hostname -s)"
    if [ "$actual" != "$expected" ]; then
      echo "Error: this configuration is for $expected, but current host is $actual" >&2
      exit 1
    fi
  '';
}
