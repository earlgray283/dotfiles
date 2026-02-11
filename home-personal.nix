{ pkgs, ... }:

{
  home.packages = [
    pkgs.opencode
    pkgs.codex
    pkgs.gemini-cli
  ];

  programs.git.signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0VEO5o1ZowITdzAIUqUbAO7zVA2QKrDHkmPFsvtPnV";
}
