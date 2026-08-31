{
  config,
  lib,
  miseTools,
  pkgs,
  release,
}:

let
  tomlFormat = pkgs.formats.toml { };

  package = pkgs.stdenv.mkDerivation {
    pname = "mise";
    inherit (release) version;

    src = pkgs.fetchurl {
      inherit (release) url hash;
    };

    sourceRoot = ".";

    installPhase = ''
      install -Dm755 "$(find . -type f -perm -u+x -name mise | sort | head -n 1)" $out/bin/mise
    '';

    meta.mainProgram = "mise";
  };

  mkBin =
    {
      name,
      bins ? [ name ],
      mainProgram ? name,
    }:
    pkgs.runCommand "mise-${name}" { meta = { inherit mainProgram; }; } ''
      mkdir -p $out/bin
      ${lib.concatMapStringsSep "\n" (
        bin: "ln -s ${config.home.homeDirectory}/.local/share/mise/shims/${bin} $out/bin/${bin}"
      ) bins}
    '';

  activationConfigDir = pkgs.runCommand "mise-activation-config" { } ''
    mkdir -p $out
    cp ${tomlFormat.generate "mise-config.toml" { tools = miseTools; }} $out/config.toml
  '';
in
{
  inherit mkBin package;

  toolsFragment = tomlFormat.generate "mise-tools.toml" { tools = miseTools; };

  activationScript = ''
    export MISE_CONFIG_DIR=${activationConfigDir}
    export PATH=${lib.makeBinPath [ pkgs.wget ]}:$PATH
    run ${lib.getExe package} install --yes
    run ${lib.getExe package} reshim
  '';
}
