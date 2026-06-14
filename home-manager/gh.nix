{ pkgs, localPackages, ... }:

{
  programs.gh = {
    enable = true;
    package = localPackages.gh;
    extensions = [ pkgs.gh-poi ];
  };
}
