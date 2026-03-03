{ inputs, pkgs, ... }:

{
  programs.codex = {
    enable = true;

    package = pkgs.llm-agents.codex;

    enableMcpIntegration = true;
  };
}
