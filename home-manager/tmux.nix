{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    escapeTime = 0;
    mouse = true;
    prefix = "C-a";

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
      set -g allow-passthrough on
      set -g monitor-bell on
      set -g bell-action any

      # key bindings
      unbind-key C-b
      bind-key C-a send-prefix
      bind '|' split-window -hf
      bind '\' split-window -h
      bind '_' split-window -vf
      bind '-' split-window -v
    '';
  };
}
