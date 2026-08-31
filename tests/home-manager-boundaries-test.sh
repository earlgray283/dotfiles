#!/usr/bin/env bash
set -euo pipefail

if rg -n 'pkgs\.(runCommand|stdenv\.mkDerivation)|builtins\.readDir|lib\.(mapAttrsToList|filterAttrs|concatMapStringsSep)' home-manager --glob '*.nix'; then
  printf 'Home Manager modules must contain settings, not generation logic\n' >&2
  exit 1
fi
