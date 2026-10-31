{ mkMiseBin, ... }:

{
  programs.direnv = {
    enable = true;
    package = mkMiseBin { name = "direnv"; };
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
