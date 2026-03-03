{ inputs, pkgs, ... }:

{
  programs.gemini-cli = {
    enable = false;

    package = pkgs.llm-agents.gemini-cli;
  };
}
