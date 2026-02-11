lint:
    nix run github:astro/deadnix -- -e

fmt:
    treefmt .

switch-home-manager-personal:
    home-manager switch --flake .#earlgray

switch-home-manager-work:
    home-manager switch --flake .#earlgray-work

switch-darwin-rebuild:
    sudo darwin-rebuild switch --flake .
