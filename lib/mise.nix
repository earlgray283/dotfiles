{
  config,
  lib,
  pkgs,
}:

let
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

in
{
  inherit mkBin;
}
