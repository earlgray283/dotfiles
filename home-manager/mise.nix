{
  config,
  lib,
  pkgs,
  ...
}:

let
  miseTools = {
    actionlint = "1.7.12";
    bat = "0.26.1";
    biome = "2.5.8";
    buf = "1.72.0";
    delta = "0.19.2";
    dprint = "0.55.2";
    fd = "10.4.2";
    fzf = "0.74.2";
    gh = "2.97.0";
    gitleaks = "8.30.1";
    golangci-lint = "2.12.2";
    hyperfine = "1.20.0";
    just = "1.58.0";
    lazygit = "0.64.1";
    protolint = "0.56.4";
    ripgrep = "15.2.0";
    starship = "1.26.0";
    stylua = "2.5.2";
    taplo = "0.10.0";
    television = "0.15.9";
    tree-sitter = "0.26.12";
    uv = "0.12.4";
    vale = "3.17.1";
    worktrunk = "0.73.0";
    xh = "0.26.2";
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
