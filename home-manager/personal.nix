{ inputs, pkgs, ... }:

{
  imports = [
    ./gemini-cli.nix
    ./codex.nix
  ];

  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];

  home.packages = [
    # Rust
    pkgs.rust-bin.stable.latest.default # Rust toolchain from rust-overlay
    pkgs.rust-analyzer
  ];

}
