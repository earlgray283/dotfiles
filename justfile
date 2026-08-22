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
    nix build --no-link .#darwinConfigurations.makabeee-macbook-air.system

switch-home-manager:
    home-manager switch --flake .#earlgray

# Confirm every tool declared in home-manager/mise.nix resolves outside /nix.
# Run from an interactive zsh: this checks PATH, and `mise activate zsh` sets PATH.
verify-mise:
    #!/usr/bin/env bash
    set -uo pipefail
    mise install --yes
    mise reshim
    fail=0
    for b in actionlint atlas bat biome buf bun cue delta docker-language-server \
             dockerfmt dprint fd fzf gh gitleaks go goimports golangci-lint \
             gopls hadolint hyperfine just lazygit lua-language-server \
             markdown-oxide node op oxlint pre-commit prettier protolint rg \
             sqlfluff sqruff starship stylua tailwindcss-language-server taplo \
             terraform terraform-ls tldr tree-sitter tv \
             typescript-language-server uv vale vscode-css-language-server \
             vscode-html-language-server wt xh yaml-language-server yamlfmt; do
      p=$(command -v "$b" || true)
      if [[ -z $p ]]; then
        echo "MISSING  $b"
        fail=1
      elif [[ $p == /nix/store/* ]]; then
        echo "IN /nix  $b -> $p"
        fail=1
      else
        printf '%-32s %s\n' "$b" "$p"
      fi
    done
    exit $fail

switch-darwin-rebuild:
    sudo darwin-rebuild switch --flake .
