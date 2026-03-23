{
  description = "nix-darwin, home-manager flake";

  nixConfig = {
    extra-substituters = [
      "https://earlgray.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "earlgray.cachix.org-1:nPH/5e9Boe2TqskXQkrRLmRVJIsVIhQkPhxOghlm0v4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
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

    tree-sitter = {
      url = "github:tree-sitter/tree-sitter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
    };

    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    claude-code-guide-skills = {
      url = "github:zebbern/claude-code-guide";
      flake = false;
    };

    superpowers-skills = {
      url = "github:obra/superpowers";
      flake = false;
    };

    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
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

            nix.settings.accept-flake-config = true;

            nix.settings.trusted-users = [
              "root"
              "earlgray"
            ];
            nix.settings.trusted-substituters = [
              "https://earlgray.cachix.org"
              "https://nix-community.cachix.org"
            ];
            nix.settings.trusted-public-keys = [
              "earlgray.cachix.org-1:nPH/5e9Boe2TqskXQkrRLmRVJIsVIhQkPhxOghlm0v4="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];

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
          inputs.mcp-servers-nix.homeManagerModules.default
        ];
        extraSpecialArgs = {
          inherit inputs;
          agent-skills = inputs.agent-skills;
          anthropic-skills = inputs.anthropic-skills;
          claude-code-guide-skills = inputs.claude-code-guide-skills;
          superpowers-skills = inputs.superpowers-skills;
          claude-plugins-official = inputs.claude-plugins-official;
        };
      };
    };
}
