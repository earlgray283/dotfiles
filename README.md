# nix-dotfiles

macOS environment managed entirely with Nix (nix-darwin + home-manager).

## Install

**1. Nix** — <https://github.com/NixOS/nix-installer>

**2. nix-darwin**
```sh
sudo nix run nix-darwin -- switch --flake .#makabeee-macbook-air
```

**3. home-manager**
```sh
nix run home-manager/master -- switch --flake .#earlgray
```

## Apply changes

```sh
just switch-darwin-rebuild    # nix-darwin (requires sudo)
just switch-home-manager      # home-manager
just fmt                      # format (treefmt)
just lint                     # lint (deadnix)
```

Dry-run before applying:
```sh
darwin-rebuild build --flake .#makabeee-macbook-air
home-manager build --flake .#earlgray
```

## Package management (`packages/`)

Managed by `bin2nix` — do not edit manually. Add packages to `config.toml`, then run:
```sh
bin2nix update          # refresh all packages
bin2nix add <owner/repo>
```

## New machine checklist (not managed by Nix)

SSH and git commit signing go through 1Password's SSH agent (see `home-manager/ssh.nix`,
`home-manager/git.nix`), so there are no raw keys to copy — sign in and the rest follows:

- **1Password** — sign in, then enable *Settings → Developer → Use the SSH agent*
- **Xcode** — install from the App Store or developer.apple.com (not distributed via Homebrew/Nix)
- **`gh auth login`** — GitHub CLI is Nix-managed, but its auth state is per-machine
- **`bin2nix`** — not in `packages/`; install with
  `cargo install --git https://github.com/earlgray283/bin2nix`
