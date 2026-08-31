#!/usr/bin/env bash

set -euo pipefail

chezmoi_bin=${CHEZMOI_BIN:?Set CHEZMOI_BIN to the chezmoi executable under test}
repo_dir=$(cd "$(dirname "$0")/.." && pwd)
test_root=$(mktemp -d)
source_dir="$test_root/source"
home_dir="$test_root/home"

cleanup() {
  rm -rf "$test_root"
}
trap cleanup EXIT

mkdir -p "$source_dir/.chezmoitemplates/nix" "$home_dir/.config/mise"
cp -R "$repo_dir/chezmoi/." "$source_dir/"

if [[ -L $source_dir/.chezmoitemplates/nix/mise-tools.toml ]]; then
  unlink "$source_dir/.chezmoitemplates/nix/mise-tools.toml"
fi

printf '%s\n' \
  '[tools]' \
  'node = "nix-version"' \
  'bun = "nix-version"' \
  > "$source_dir/.chezmoitemplates/nix/mise-tools.toml"

printf '%s\n' \
  '[tools]' \
  'node = "runtime-version"' \
  'runtime-only = "1.0"' \
  '' \
  '[settings]' \
  'experimental = true' \
  > "$home_dir/.config/mise/config.toml"

HOME="$home_dir" XDG_CONFIG_HOME="$home_dir/.config" \
  "$chezmoi_bin" --source "$source_dir" --destination "$home_dir" apply \
  "$home_dir/.config/mise/config.toml"

rg -F 'node = "nix-version"' "$home_dir/.config/mise/config.toml"
rg -F 'bun = "nix-version"' "$home_dir/.config/mise/config.toml"
rg -F 'runtime-only = "1.0"' "$home_dir/.config/mise/config.toml"
rg -F 'experimental = true' "$home_dir/.config/mise/config.toml"
