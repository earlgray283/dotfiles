{
  config,
  lib,
  pkgs,
  ...
}:

let
  mise = import ../lib/mise.nix {
    inherit
      config
      lib
      pkgs
      ;
  };
in
{
  _module.args.mkMiseBin = mise.mkBin;

  programs.mise = {
    enable = true;
    package = pkgs.mise;
    enableZshIntegration = true;
  };

  xdg.configFile."mise/config.toml".source = ../mise/mise.toml;
  xdg.configFile."mise/mise.lock".source = ../mise/mise.lock;
}
