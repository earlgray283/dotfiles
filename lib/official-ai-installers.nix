{ pkgs }:

let
  mkInstaller =
    {
      name,
      preInstall ? "",
      url,
    }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.coreutils
        pkgs.curl
        pkgs.jq
        pkgs.zstd
      ];
      text = ''
        ${preInstall}
        installer="$(mktemp)"
        trap 'rm -f "$installer"' EXIT
        curl -fsSL --output "$installer" ${pkgs.lib.escapeShellArg url}
        ${pkgs.bash}/bin/bash "$installer" "$@"
      '';
    };
in
{
  claude-code-installer = mkInstaller {
    name = "claude-code-installer";
    url = "https://claude.ai/install.sh";
  };

  codex-installer = mkInstaller {
    name = "codex-installer";
    url = "https://chatgpt.com/codex/install.sh";
    preInstall = ''
      export CODEX_NON_INTERACTIVE=1
    '';
  };

  muse-code-installer = mkInstaller {
    name = "muse-code-installer";
    url = "https://dev.meta.ai/install.sh";
  };
}
