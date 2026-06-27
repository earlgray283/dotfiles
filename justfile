lint:
    nix run github:astro/deadnix -- -e

fmt:
    treefmt .

switch-home-manager:
    home-manager switch --flake .#earlgray

switch-darwin-rebuild:
    sudo darwin-rebuild switch --flake .
