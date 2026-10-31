# Deploy Home Manager generated files as writable copies instead of store symlinks.
# Before writeBoundary, abort when a target differs from both the new source and
# the last deployed copy (edited outside Nix). HM_EDITABLE_FORCE=1 overwrites anyway.
{
  lib,
  jq,
  stateDir,
}:
files:
let
  call =
    fn:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: file:
        "${fn} ${
          lib.escapeShellArgs [
            name
            "${file.source}"
            file.target
          ]
        }"
      ) files
    );
in
{
  editableConfigsCheck = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    editable_drift=0
    same_content() {
      cmp -s "$1" "$2" && return 0
      local a b
      a=$(${jq}/bin/jq -S . "$1" 2>/dev/null) || return 1
      b=$(${jq}/bin/jq -S . "$2" 2>/dev/null) || return 1
      [[ $a == "$b" ]]
    }
    check_editable() {
      local deployed=${lib.escapeShellArg stateDir}/$1
      if [[ -L $3 || ! -e $3 ]] || same_content "$2" "$3"; then
        return 0
      fi
      if [[ -f $deployed ]] && same_content "$deployed" "$3"; then
        return 0
      fi
      editable_drift=1
      warnEcho "Drift detected in $3 (edited outside Nix):"
      local base=$2 label=nix
      if [[ -f $deployed ]]; then
        base=$deployed label="last deployed"
      fi
      diff -u --label "$3 ($label)" --label "$3 (current)" "$base" "$3" || true
    }
    ${call "check_editable"}
    if [[ $editable_drift == 1 && ''${HM_EDITABLE_FORCE:-} != 1 ]]; then
      errorEcho "Port the changes above to Nix, or rerun with HM_EDITABLE_FORCE=1 to overwrite."
      exit 1
    fi
    unset -f check_editable same_content
  '';

  editableConfigsDeploy = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    deploy_editable() {
      run mkdir -p "$(dirname "$3")" ${lib.escapeShellArg stateDir}
      if ! cmp -s "$2" "$3"; then
        run install -m 644 "$2" "$3"
      fi
      run install -m 644 "$2" ${lib.escapeShellArg stateDir}/"$1"
    }
    ${call "deploy_editable"}
    unset -f deploy_editable
  '';
}
