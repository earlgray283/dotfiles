{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./options.nix
    ./theme.nix
    ./languages.nix
    ./ui.nix
    ./editor.nix
    ./completion.nix
    ./formatting.nix
    ./linting.nix
    ./keymaps.nix
  ];

  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        pluginOverrides = {
          nvim-telescope = inputs.nvim-telescope;
        };
      };
    };
  };
}
