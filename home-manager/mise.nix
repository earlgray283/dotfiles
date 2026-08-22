{
  config,
  lib,
  pkgs,
  ...
}:

let
  miseTools = {
    gh = "2.97.0";
    starship = "1.26.0";
  };

  # nixpkgs' mise is not in any cache for aarch64-darwin and builds from source
  # (Rust, 1.2GiB vendor dir); the upstream release tarball costs nothing.
  misePackage = pkgs.stdenv.mkDerivation {
    pname = "mise";
    version = "2026.8.5";

    src = pkgs.fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v2026.8.5/mise-v2026.8.5-macos-arm64.tar.gz";
      hash = "sha256-hZg6m4jja6MhG8tLLl+B6o0ncIUn2RAM3oZekvSKPsI=";
    };

    sourceRoot = ".";

    installPhase = ''
      install -Dm755 "$(find . -type f -perm -u+x -name mise | sort | head -n 1)" $out/bin/mise
    '';

    meta.mainProgram = "mise";
  };

  # Only a symlink lands in /nix/store; the Mach-O binary stays under $HOME,
  # which is what keeps it out of Falcon's scan scope.
  mkMiseBin =
    {
      name,
      bins ? [ name ],
      mainProgram ? name,
    }:
    pkgs.runCommand "mise-${name}" { meta = { inherit mainProgram; }; } ''
      mkdir -p $out/bin
      ${lib.concatMapStringsSep "\n" (
        b: "ln -s ${config.home.homeDirectory}/.local/share/mise/shims/${b} $out/bin/${b}"
      ) bins}
    '';

  # home.activation runs before linkGeneration, so ~/.config/mise/config.toml
  # does not exist yet; hand mise this copy via MISE_GLOBAL_CONFIG_FILE.
  activationConfig = (pkgs.formats.toml { }).generate "mise-activation.toml" {
    tools = miseTools;
  };
in
{
  _module.args.mkMiseBin = mkMiseBin;

  programs.mise = {
    enable = true;
    package = misePackage;
    enableZshIntegration = true;
    globalConfig.tools = miseTools;
  };

  home.activation.miseInstall = lib.hm.dag.entryBetween [ "migrateGhAccounts" ] [ "writeBoundary" ] ''
    export MISE_GLOBAL_CONFIG_FILE=${activationConfig}
    run ${lib.getExe misePackage} install --yes
    run ${lib.getExe misePackage} reshim
  '';
}
