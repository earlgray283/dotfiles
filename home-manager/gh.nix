{ pkgs, mkMiseBin, ... }:

{
  programs.gh = {
    enable = true;
    package = mkMiseBin { name = "gh"; };
    extensions = [ pkgs.gh-poi ];
  };
}
