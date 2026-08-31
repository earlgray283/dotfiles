{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.chezmoi ];

  xdg.configFile."chezmoi/chezmoi.toml".text = ''
    sourceDir = "${config.home.homeDirectory}/dev/dotfiles/chezmoi"
  '';

  home.activation.chezmoiApply = lib.hm.dag.entryAfter [ "linkGeneration" "miseInstall" ] ''
    run ${lib.getExe pkgs.chezmoi} apply
  '';
}
