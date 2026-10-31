# CI drives these recipes through `nix run .#just`, so a change here changes
# what CI runs. `.#deadnix` and `.#just` pin those tools to this flake's nixpkgs
# rather than resolving them afresh on every run.
# Keep the comment above each recipe to one line: `just --list` shows only the
# last line as its description.

set shell := ["bash", "-euo", "pipefail", "-c"]

mise := 'mise --cd "' + justfile_directory() / 'mise"'

# The global config is a read-only store copy of mise/mise.toml; mise must not try to lock it.
export MISE_IGNORED_CONFIG_PATHS := env_var("HOME") / ".config/mise/config.toml"
ai_tests := "declarative-agent-configs editable-configs binary-sources codex-skills ponytail-plugin go-modern-guidelines-plugin caveman-plugin"

_default:
    @just --list

# Report dead nix code.
lint *args="--fail":
    nix run .#deadnix -- {{args}} .

# Same lint, but rewrites the sources instead of only reporting.
lint-fix: (lint "-e")

fmt:
    nix fmt

flake-check:
    nix flake check --print-build-logs

_build attr:
    nix build --print-build-logs --no-link .#{{attr}}

build-home-manager: (_build "homeConfigurations.earlgray.activationPackage")
build-darwin: (_build "darwinConfigurations.makabeee-macbook-pro.system")

# Run tests/<name>-test.sh for each name.
test *names:
    for t in {{names}}; do bash "tests/$t-test.sh"; done

# Test Claude Code and Codex configuration, extensions, and installers.
test-ai: (test ai_tests)

# Everything CI runs (CI calls the recipes one by one, for per-step logs).
check: flake-check lint (test ai_tests "home-manager-boundaries mise-config") build-home-manager build-darwin

switch-home-manager:
    home-manager switch --flake .#earlgray

switch-darwin-rebuild:
    sudo darwin-rebuild switch --flake .

# Apply nix-darwin (Homebrew provides AeroSpace), then Home Manager.
switch-all: switch-darwin-rebuild switch-home-manager

# Install or update Claude Code through Anthropic's official latest-channel installer.
install-claude-code:
    nix run .#claude-code-installer -- latest

# Install or update Codex through OpenAI's official standalone installer.
install-codex:
    nix run .#codex-installer

# Install or update Muse Code through Meta's official installer.
install-muse-code:
    nix run .#muse-code-installer

# Install or update both AI CLIs through their official installers.
install-ai: install-claude-code install-codex

# Update Claude Code through its native updater.
update-claude-code:
    claude update

# Update Codex through its native updater.
update-codex:
    codex update

# Update both installed AI CLIs without rebuilding their static configuration.
update-ai: update-claude-code update-codex

# Install mise itself into ~/.local/bin through the official installer.
install-mise-cli:
    curl -fsSL https://mise.run | sh
    ~/.local/bin/mise --version

# Install every tool pinned by the tracked mise configuration.
install-mise: && install-completions
    {{mise}} install --locked --yes

# Generate zsh completions from each CLI itself into ~/.local/share/zsh/site-functions.
[script("bash")]
install-completions:
    set -uo pipefail
    # Shims resolve tools through the global config that this justfile tells mise to ignore.
    unset MISE_IGNORED_CONFIG_PATHS
    export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
    dir="$HOME/.local/share/zsh/site-functions"
    mkdir -p "$dir"
    # name|command that prints the zsh completion; just's comes from nix (home-manager/zsh.nix).
    while IFS='|' read -r name cmd; do
      if out=$(bash -c "$cmd" 2>/dev/null) && [[ -n $out ]]; then
        printf '%s\n' "$out" > "$dir/_$name"
      else
        echo "SKIP $name: '$cmd' failed" >&2
      fi
    done <<'EOF'
    bat|bat --completion zsh
    buf|buf completion zsh
    bun|bun completions zsh
    colima|colima completion zsh
    delta|delta --generate-completion zsh
    docker|docker completion zsh
    dprint|dprint completions zsh
    fd|fd --gen-completions zsh
    gh|gh completion -s zsh
    gitleaks|gitleaks completion zsh
    golangci-lint|golangci-lint completion zsh
    herdr|herdr completion zsh
    lazygit|lazygit completion zsh
    limactl|limactl completion zsh
    mise|mise completion zsh
    op|op completion zsh
    rg|rg --generate complete-zsh
    starship|starship completions zsh
    taplo|taplo completions zsh
    uv|uv generate-shell-completion zsh
    wt|wt config shell completions zsh
    EOF

# Upgrade mise tool pins and refresh their lock metadata.
update-mise: && install-completions
    ~/.local/bin/mise self-update --yes
    {{mise}} upgrade --bump --yes --exclude python
    {{mise}} upgrade --yes python
    {{mise}} lock --platform macos-arm64 --yes

# Bump flake inputs. Apply with switch-home-manager.
update-nix:
    nix flake update

# Bump flake inputs and update official-installer CLIs (Claude Code, Codex). Does not switch.
update-all: update-nix update-ai

# Upgrade everything: flake inputs, AI CLIs, mise tools. Does not switch.
update: update-nix update-ai update-mise

# Update everything, then apply it with switch-home-manager.
upgrade: update switch-home-manager

# Confirm every executable mise provides resolves outside /nix.
# Run from an interactive zsh: this checks PATH, and `mise activate zsh` sets PATH.
[script("bash")]
verify-mise:
    set -uo pipefail
    {{mise}} install --yes
    {{mise}} reshim
    fail=0
    for b in $(MISE_IGNORED_CONFIG_PATHS= {{mise}} bin-paths | xargs -I{} fd -t x -d 1 . {} -x echo '{/}' | sort -u); do
      p=$(command -v "$b" || true)
      if [[ -z $p || $p == /nix/store/* ]]; then echo "BAD  $b -> ${p:-MISSING}"; fail=1; fi
    done
    exit $fail
