{ inputs, pkgs, ... }:

{
  programs.copilot-cli = {
    enable = true;

    package = pkgs.llm-agents.copilot-cli;
  };
}
