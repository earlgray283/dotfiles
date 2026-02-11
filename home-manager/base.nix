{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./starship.nix
    ./ghostty.nix
    ./aerospace.nix
    ./git.nix
    ./zsh.nix
    ./sheldon.nix
    ./ssh.nix
    ./tmux.nix
    ./1password-shell-plugin.nix
    ./claude-code/claude-code.nix
    ./mcp.nix
    ./direnv.nix
  ];

  # Allow unfree packages (e.g. terraform)
  nixpkgs.config.allowUnfree = true;

  # Enable overlays
  nixpkgs.overlays = [
    inputs.claude-code-nix.overlays.default
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
    pkgs.fd
    pkgs.bat
    pkgs.ripgrep
    pkgs.eza
    pkgs.delta
    pkgs.starship
    pkgs.skim
    pkgs.tealdeer
    pkgs.xh
    pkgs.television
    pkgs.just
    pkgs.tree-sitter
    pkgs.google-cloud-sdk
    pkgs._1password-cli

    # Git Tools
    pkgs.lazygit
    pkgs.gh
    pkgs.gitleaks
    pkgs.pre-commit

    # Editors
    pkgs.neovim

    # Go
    pkgs.go
    pkgs.gopls
    pkgs.gotools # Go tools including goimports
    pkgs.golangci-lint

    # Python
    pkgs.uv

    # Lua
    pkgs.lua
    pkgs.lua-language-server
    pkgs.stylua
    pkgs.luarocks

    # JavaScript/TypeScript
    pkgs.nodejs
    pkgs.bun
    pkgs.deno
    pkgs.typescript-language-server
    pkgs.vtsls # TypeScript Language Server
    pkgs.tailwindcss-language-server
    pkgs.oxlint
    pkgs.biome
    pkgs.dprint

    # nix
    pkgs.nil # Nix Language Server
    pkgs.nixd # Nix Language Server
    pkgs.nixfmt
    pkgs.nixfmt-tree

    # YAML
    pkgs.yamlfmt
    pkgs.yaml-language-server
    pkgs.actionlint

    # TOML
    pkgs.taplo # TOML toolkit

    # Markdown
    pkgs.markdown-oxide # Markdown LSP

    # Docker
    pkgs.docker-language-server
    pkgs.hadolint

    # Terraform
    pkgs.terraform
    pkgs.terraform-ls

    # Protocol Buffers
    pkgs.buf
    pkgs.protolint

    # Linters/Formatters
    pkgs.vale # Prose linter

    # DB/SQL
    pkgs.atlas
    pkgs.sqruff # SQL linter
    # pkgs.cockroachdb            # Linux only - not available on macOS
  ];

  home.file = { };

  home.sessionVariables = { };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
