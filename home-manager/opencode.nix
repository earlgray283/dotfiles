{ inputs, pkgs, ... }:

{
  programs.opencode = {
    enable = true;

    package = pkgs.opencode.override { };

    enableMcpIntegration = true;
  };
}
