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

mkdir -p "$source_dir/.chezmoitemplates/nix" "$home_dir/.codex"
cp -R "$repo_dir/chezmoi/." "$source_dir/"
if [[ -L $source_dir/.chezmoitemplates/nix/codex-mcp-servers.toml ]]; then
  unlink "$source_dir/.chezmoitemplates/nix/codex-mcp-servers.toml"
fi

printf '%s\n' \
  '[mcp_servers.context7]' \
  'url = "https://mcp.context7.com/mcp/oauth"' \
  > "$source_dir/.chezmoitemplates/nix/codex-mcp-servers.toml"

printf '%s\n' \
  'model = "runtime-model"' \
  '' \
  '[plugins."runtime"]' \
  'enabled = true' \
  '' \
  '[hooks.state."runtime"]' \
  'trusted_hash = "sha256:runtime"' \
  '' \
  '[mcp_servers.stale]' \
  'url = "https://stale.example/mcp"' \
  > "$home_dir/.codex/config.toml"

HOME="$home_dir" XDG_CONFIG_HOME="$test_root/config" \
  "$chezmoi_bin" --source "$source_dir" --destination "$home_dir" apply

rg -F '[plugins.runtime]' "$home_dir/.codex/config.toml"
rg -F '[hooks.state.runtime]' "$home_dir/.codex/config.toml"
rg -F 'model = "runtime-model"' "$home_dir/.codex/config.toml"
rg -F 'enabled = true' "$home_dir/.codex/config.toml"
rg -F 'trusted_hash = "sha256:runtime"' "$home_dir/.codex/config.toml"
rg -F 'https://mcp.context7.com/mcp/oauth' "$home_dir/.codex/config.toml"
if rg -F 'https://stale.example/mcp' "$home_dir/.codex/config.toml"; then
  exit 1
fi

rm "$home_dir/.codex/config.toml"
HOME="$home_dir" XDG_CONFIG_HOME="$test_root/config" \
  "$chezmoi_bin" --source "$source_dir" --destination "$home_dir" apply

rg -F '[features]' "$home_dir/.codex/config.toml"
rg -F 'https://mcp.context7.com/mcp/oauth' "$home_dir/.codex/config.toml"
rg -F 'trusted_hash = "sha256:bc8fcabc7e0a38d90e26757207c40907b8b6e967256e6eb74f8f49f9cc4bf1"' "$home_dir/.codex/config.toml"

: > "$home_dir/.codex/config.toml"
HOME="$home_dir" XDG_CONFIG_HOME="$test_root/config" \
  "$chezmoi_bin" --source "$source_dir" --destination "$home_dir" apply

rg -F '[features]' "$home_dir/.codex/config.toml"
rg -F 'https://mcp.context7.com/mcp/oauth' "$home_dir/.codex/config.toml"
rg -F 'trusted_hash = "sha256:bc8fcabc7e0a38d90e26757207c40907b8b6e967256e6eb74f8f49f9cc4bf1"' "$home_dir/.codex/config.toml"
