{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    escapeTime = 0;
    mouse = true;
    prefix = "C-Space";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "frappe"
        '';
      }
    ];

    extraConfig = ''
      # true color
      set -sg terminal-overrides ",*:RGB"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set -as terminal-features ',*:clipboard'

      # key bindings
      unbind-key C-b
      bind-key C-Space send-prefix
      bind | split-window -h  # prefix-| で垂直分割
      bind _ split-window -v  # prefix-_ で水平分割
    '';
  };
}
