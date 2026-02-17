{
  description = "nix-darwin, home-manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-nix = {
      # Ref: https://github.com/earlgray283/dotfiles/issues/1
      url = "github:sadjow/claude-code-nix";
      # url = "github:sadjow/claude-code-nix?ref=v2.1.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli = {
      url = "github:openai/codex";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-telescope = {
      url = "github:nvim-telescope/telescope.nvim/master";
      flake = false;
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tree-sitter = {
      url = "github:tree-sitter/tree-sitter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-index-database,
      ...
    }:
    let
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            _1password-cli = prev._1password-cli.overrideAttrs (old: rec {
              version = "2.33.0-beta.02";
              # nix store prefetch-file --hash-type sha256 "https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_apple_universal_v${version}.pkg"
              src = prev.fetchurl {
                url = "https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_apple_universal_v${version}.pkg";
                hash = "sha256-inHfXY1KlttPnTeSIH2kTfBIvslASyqkUDO1YHZXQ0U=";
              };
            });
          })
        ];
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#makabeee-macbook-air
      darwinConfigurations."makabeee-macbook-air" = nix-darwin.lib.darwinSystem {
        modules = [
          ./nix-darwin/configuration.nix
          {
            # Necessary for using flakes on this system.
            nix.settings.experimental-features = "nix-command flakes";

            # Set Git commit hash for darwin-version.
            system.configurationRevision = self.rev or self.dirtyRev or null;

            # The platform the configuration will be used on.
            nixpkgs.hostPlatform = "aarch64-darwin";
          }
        ];
        specialArgs = { inherit inputs; };
      };

      homeConfigurations."earlgray" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/base.nix
          ./home-manager/personal.nix
          nix-index-database.homeModules.default
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      homeConfigurations."earlgray-work" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/base.nix
          ./home-manager/work.nix
          nix-index-database.homeModules.default
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
