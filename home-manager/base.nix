{
  pkgs,
  ...
}:

{
  imports = [
    ./starship.nix
    ./ghostty.nix
    ./aerospace.nix
    ./karabiner.nix
    ./gh.nix
    ./git.nix
    ./zsh.nix
    ./ssh.nix
    ./herdr.nix
    ./ai
    ./opencode.nix
    ./muse.nix
    ./editable-configs.nix
    ./mise.nix
    ./television.nix
    ./direnv.nix
    ./docker.nix
    ./neovim
  ];

  # Allow unfree packages (e.g. terraform)
  nixpkgs.config.allowUnfree = true;

  home.username = "earlgray";
  home.homeDirectory = "/Users/earlgray";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = [
    # nix
    pkgs.nixd # Nix Language Server
    pkgs.nixfmt

    # Docker
    # pkgs.cockroachdb            # Linux only - not available on macOS
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
