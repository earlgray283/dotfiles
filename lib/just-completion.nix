{ pkgs }:

# just itself comes from mise; nixpkgs just is used only to generate the completion.
pkgs.runCommand "just-zsh-completion" { } ''
  mkdir -p $out/share/zsh/site-functions
  ${pkgs.lib.getExe pkgs.just} --completions zsh > $out/share/zsh/site-functions/_just
''
