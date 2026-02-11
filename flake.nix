{
  description = "nix-darwin, home-manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    claude-code-nix.url = "github:sadjow/claude-code-nix";
    claude-code-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

   outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-index-database, claude-code-nix, ... }:
   let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#makabeee-macbook-air
    darwinConfigurations."makabeee-macbook-air" = nix-darwin.lib.darwinSystem {
      modules = [
        ./configuration.nix
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
        ./home-base.nix
        ./home-personal.nix
        nix-index-database.homeModules.default
      ];
      extraSpecialArgs = { inherit inputs; };
    };

    homeConfigurations."earlgray-work" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home-base.nix
        ./home-work.nix
        nix-index-database.homeModules.default
      ];
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
