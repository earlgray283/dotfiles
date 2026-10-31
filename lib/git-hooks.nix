{ pkgs, shimsDir }:

{
  # gitleaks comes from mise; fail closed so a missing install cannot silently skip the scan.
  pre-commit = pkgs.writeShellScript "pre-commit" ''
    export PATH="${shimsDir}:$PATH"
    if ! command -v gitleaks >/dev/null; then
      echo "pre-commit: gitleaks not found; run 'just install-mise'" >&2
      exit 1
    fi
    exec gitleaks git --staged --redact --no-banner
  '';
}
