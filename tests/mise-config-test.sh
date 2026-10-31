#!/usr/bin/env bash
set -euo pipefail

generation=$(nix build --no-link --print-out-paths path:.#homeConfigurations.earlgray.activationPackage)
mise_config="$generation/home-files/.config/mise/config.toml"
session_vars="$generation/home-path/etc/profile.d/hm-session-vars.sh"

force_state=$(nix eval --impure --json --expr '
  let
    flake = builtins.getFlake ("path:" + toString ./.);
    files = flake.homeConfigurations.earlgray.config.xdg.configFile;
  in {
    config = files."mise/config.toml".force;
    lock = files."mise/mise.lock".force;
  }
')
test "$force_state" = '{"config":true,"lock":true}'

test -L "$mise_config"

mise_bin=$(command -v mise)
mise_env=$(env -u GOBIN MISE_CONFIG_FILE="$mise_config" "$mise_bin" env --json)
if jq -e 'has("GOBIN")' <<<"$mise_env" >/dev/null; then
  printf 'mise must not bind GOBIN to the selected Go version\n' >&2
  exit 1
fi

rg -qF '/Users/earlgray/go/bin' "$session_vars"

if rg -q 'mise[^[:cntrl:]]+ (install|reshim)' "$generation/activate"; then
  printf 'Home Manager activation must not install mise tools\n' >&2
  exit 1
fi

install_recipe=$(just --show install-mise)
update_recipe=$(just --show update-mise)
[[ "$install_recipe" == *'install --locked --yes'* ]]
[[ "$update_recipe" == *'upgrade --bump --yes'* ]]
