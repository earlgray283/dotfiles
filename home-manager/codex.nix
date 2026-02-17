{ inputs, pkgs, ... }:

{
  programs.codex = {
    enable = true;

    package = inputs.codex-cli.packages.${pkgs.system}.default;

    enableMcpIntegration = true;
  };
}
