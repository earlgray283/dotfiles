# The darwinConfigurations attribute name must match the machine's actual
# hostname (darwin-rebuild's own lookup relies on this), so reading it here
# keeps this file working across renames instead of hardcoding it.
hostname := `scutil --get LocalHostName`

# .#deadnix pins the linter to this flake's nixpkgs rather than resolving
# github:astro/deadnix afresh on every run.
lint:
    nix run .#deadnix -- -e .

fmt:
    nix fmt

# Build both configurations without applying them, as CI does.
check:
    nix flake check
    nix build --no-link .#homeConfigurations.earlgray.activationPackage
    nix build --no-link .#darwinConfigurations.{{ hostname }}.system

switch-home-manager:
    home-manager switch --flake .#earlgray

switch-darwin-rebuild:
    sudo darwin-rebuild switch --flake .
