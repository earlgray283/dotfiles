{ config, ... }:

{
  programs.sheldon = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      shell = "zsh";
      match = [
        "{{ name }}.plugin.zsh"
        "{{ name }}.zsh"
        "{{ name }}.sh"
        "{{ name }}.zsh-theme"
        "*.plugin.zsh"
        "*.zsh"
        "*.sh"
        "*.zsh-theme"
        "completion.zsh.inc"
      ];
      plugins = {
        "01-zsh-defer" = {
          github = "romkatv/zsh-defer";
        };
        "02-zsh-completions" = {
          github = "zsh-users/zsh-completions";
        };
        "03-zsh-autosuggestions" = {
          github = "zsh-users/zsh-autosuggestions";
        };
        "04-zsh-syntax-highlighting" = {
          github = "zsh-users/zsh-syntax-highlighting";
        };
        "10-zfunc" = {
          local = "${config.home.homeDirectory}/.zfunc";
          apply = [ "fpath" ];
          use = [ "_*" ];
        };
        "11-site-functions" = {
          local = "/opt/homebrew/share/zsh/site-functions";
          apply = [ "fpath" ];
        };
        "12-gcloud-zsh-completion" = {
          local = "${config.home.homeDirectory}/.nix-profile/google-cloud-sdk";
          use = [ "path.zsh.inc" ];
          apply = [ "source" ];
        };
        "13-bun-completion" = {
          local = "${config.home.homeDirectory}/.bun";
          use = [ "_bun" ];
          apply = [ "fpath" ];
        };
        "14-compinit" = {
          inline = "autoload -Uz compinit && compinit";
        };
        "99-credentials" = {
          local = "${config.home.homeDirectory}/.credentials";
          use = [ "credentials.sh" ];
          apply = [ "defer" ];
        };
      };
      templates.defer = ''
        {{ hooks?.pre | nl }}{% for file in files %}zsh-defer source "{{ file }}"
        {% endfor %}{{ hooks?.post | nl }}'';
    };
  };
}
