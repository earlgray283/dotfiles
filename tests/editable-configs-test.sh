#!/usr/bin/env bash
set -euo pipefail

generation=$(nix build --no-link --print-out-paths path:.#homeConfigurations.earlgray.activationPackage)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

check_fn=$(awk '/^check_editable\(\)/,/^}/' "$generation/activate" |
  awk '{ sub(/local deployed=[^$]*\$1/, "local deployed=$STATE_DIR/$1"); print }')
rg -qF 'local deployed=$STATE_DIR/$1' <<<"$check_fn"
same_fn=$(awk '/^same_content\(\)/,/^}/' "$generation/activate")

# Prints the drift flag for: check <deployed|-> <source> <target>
check() {
  local state="$work/state"
  rm -rf "$state" && mkdir -p "$state"
  [[ $1 == - ]] || printf '%s' "$1" >"$state/f"
  printf '%s' "$2" >"$work/source"
  rm -f "$work/target"
  case $3 in
  @missing) ;;
  @symlink) ln -s "$work/source" "$work/target" ;;
  *) printf '%s' "$3" >"$work/target" ;;
  esac
  STATE_DIR=$state bash -c "set -eu
    warnEcho() { :; }
    editable_drift=0
    $same_fn
    $check_fn
    check_editable f \"\$1\" \"\$2\" >/dev/null
    echo \$editable_drift" _ "$work/source" "$work/target"
}

expect() {
  local want=$1 got
  shift
  got=$(check "$@")
  if [[ $got != "$want" ]]; then
    printf 'check %s: want drift=%s, got %s\n' "$*" "$want" "$got" >&2
    exit 1
  fi
}

expect 0 - new @missing
expect 0 - new @symlink
expect 0 - new new
expect 1 - new edited
expect 0 old new old
expect 0 old new new
expect 1 old new edited
expect 0 - '{"a":1,"b":2}' '{"b":2,"a":1}'
expect 1 - '{"a":1}' '{"a":2}'
expect 1 - 'a = 1' 'a = 2'

rg -qF 'HM_EDITABLE_FORCE:-} != 1' "$generation/activate"
