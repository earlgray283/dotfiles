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
          apply = [ "defer" ];
        };
        "04-zsh-syntax-highlighting" = {
          github = "zsh-users/zsh-syntax-highlighting";
          apply = [ "defer" ];
        };
        "10-zfunc" = {
          local = "${config.home.homeDirectory}/.zfunc";
          apply = [ "fpath" ];
          use = [ "_*" ];
        };
        "11-site-functions-homebrew" = {
          local = "/opt/homebrew/share/zsh/site-functions";
          apply = [ "fpath" ];
        };
        "12-site-functions-nix" = {
          local = "${config.home.homeDirectory}/.nix-profile/share/zsh/site-functions";
          apply = [ "fpath" ];
        };
        "13-gcloud-zsh-completion" = {
          local = "${config.home.homeDirectory}/.nix-profile/google-cloud-sdk";
          use = [ "path.zsh.inc" ];
          apply = [ "source" ];
        };
        "14-bun-completion" = {
          local = "${config.home.homeDirectory}/.bun";
          use = [ "_bun" ];
          apply = [ "fpath" ];
        };
        "15-compinit" = {
          inline = ''
            autoload -Uz compinit && compinit
            () {
              emulate -L zsh
              setopt extended_glob
              if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
                compinit
              else 
                compinit -C
              fi
            }
          '';
        };
        "99-credentials" = {
          local = "${config.home.homeDirectory}/.credentials";
          use = [ "credentials.sh" ];
          apply = [ "defer" ];
        };
        "99-post-init" = {
          inline = ''
            zsh-defer -c 'export JAVA_HOME=$(/usr/libexec/java_home -v 25)'
            zsh-defer -c 'eval "$(tv init zsh)"'
          '';
        };
      };
      templates.defer = ''
        {{ hooks?.pre | nl }}{% for file in files %}zsh-defer source "{{ file }}"
        {% endfor %}{{ hooks?.post | nl }}'';
    };
  };
}
