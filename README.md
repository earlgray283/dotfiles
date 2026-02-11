# nix-dotfiles

## Install

### 1. Nix(Lix)

Ref <https://lix.systems/install/>

### 2. nix-darwin

```sh
nix run nix-darwin -- switch --flake .#makabeee-macbook-air
```

### 3. home-manager

```sh
nix run home-manager/master -- switch --flake .

# switch profile
nix run home-manager/master -- switch --flake.#earlgray-work
```

## Apply changes

### macOS settings

```sh
# Dry-run
darwin-rebuild build --flake .#makabeee-macbook-air

# Apply
sudo darwin-rebuild switch --flake .#makabeee-macbook-air
```

### home-manager

```sh
# Dry-run
home-manager build --flake .#earlgray
home-manager build --flake .#earlgray-work

# Apply
home-manager switch --flake .#earlgray        # Personal
home-manager switch --flake .#earlgray-work   # Work
```

