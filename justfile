# CI drives these recipes through `nix run .#just`, so a change here changes
# what CI runs. `.#deadnix` and `.#just` pin those tools to this flake's nixpkgs
# rather than resolving them afresh on every run.
# Keep the comment above each recipe to one line: `just --list` shows only the
# last line as its description.

# Report dead nix code.
lint:
    nix run .#deadnix -- --fail .

# Same lint, but rewrites the sources instead of only reporting.
lint-fix:
    nix run .#deadnix -- -e .

fmt:
    nix fmt

flake-check:
    nix flake check --print-build-logs

build-home-manager:
    nix build --print-build-logs --no-link .#homeConfigurations.earlgray.activationPackage

build-darwin:
    nix build --print-build-logs --no-link .#darwinConfigurations.makabeee-macbook-pro.system

test-chezmoi:
    nix shell .#chezmoi -c env CHEZMOI_BIN=chezmoi bash tests/chezmoi-codex-modify-test.sh
    nix shell .#chezmoi -c env CHEZMOI_BIN=chezmoi bash tests/chezmoi-managed-configs-test.sh

test-codex-skills:
    bash tests/codex-skills-test.sh

test-ponytail-plugin:
    bash tests/ponytail-plugin-test.sh

test-go-modern-guidelines-plugin:
    bash tests/go-modern-guidelines-plugin-test.sh

test-caveman-plugin:
    bash tests/caveman-plugin-test.sh

# Everything CI runs (CI calls the recipes one by one, for per-step logs).
check: flake-check lint test-chezmoi test-codex-skills test-ponytail-plugin test-go-modern-guidelines-plugin test-caveman-plugin build-home-manager build-darwin

switch-home-manager:
    home-manager switch --flake .#earlgray

apply-dotfiles:
    just switch-home-manager

# Confirm every tool declared in home-manager/mise.nix resolves outside /nix.
# Run from an interactive zsh: this checks PATH, and `mise activate zsh` sets PATH.
verify-mise:
    #!/usr/bin/env bash
    set -uo pipefail
    mise install --yes
    mise reshim
    fail=0
    for b in actionlint atlas bat biome buf bun clang clang-format clangd cue delta docker-language-server \
             dockerfmt dprint fd fzf gh gitleaks go goimports golangci-lint \
             gopls hadolint hyperfine just lazygit lua-language-server \
             markdown-oxide node op oxlint pre-commit prettier protolint \
             rg rustfmt sqlfluff sqruff starship stylua tailwindcss-language-server taplo \
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
