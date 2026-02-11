{ inputs, pkgs, ... }:

{
  imports = [
    ./gemini-cli.nix
    ./codex.nix
  ];

  nixpkgs.overlays = [
    inputs.claude-code-nix.overlays.default
    inputs.rust-overlay.overlays.default
  ];

  home.packages = [
    # Rust
    pkgs.rust-bin.stable.latest.default # Rust toolchain from rust-overlay
    pkgs.rust-analyzer
  ];

  programs.git.signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0VEO5o1ZowITdzAIUqUbAO7zVA2QKrDHkmPFsvtPnV";
}
