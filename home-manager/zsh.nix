{ pkgs, config, ... }:

let
  # Plugins previously fetched by sheldon from GitHub HEAD. Pinning them to
  # nixpkgs keeps them in flake.lock and removes sheldon's mutable lock file,
  # which nix cannot invalidate: files in the store always carry mtime 1970,
  # so sheldon never noticed a changed plugins.toml and kept serving a stale
  # script (that is how a full compinit ran on every shell start for months).
  zsh-defer = "${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh";
  zsh-autosuggestions = "${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
  zsh-syntax-highlighting = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
  zsh-completions = "${pkgs.zsh-completions}/share/zsh/site-functions";
in
{
  programs.zsh = {
    enable = true;

    history.ignoreAllDups = true; # setopt HIST_IGNORE_ALL_DUPS

    setOptions = [
      "INTERACTIVE_COMMENTS" # Allow comments in interactive shell
    ];

    shellAliases = {
      ls = "eza --icons=auto";
      fd = "fd -I --no-ignore-vcs";
      mv = "mv -v";
      gitroot = "cd `git rev-parse --show-superproject-working-tree --show-toplevel | head -1`";
      sed = "gsed";
      xargs = "gxargs";
    };

    # Completion is initialised by hand below, after fpath is complete.
    completionInit = "";

    initContent = ''
      [[ -n $ZPROF ]] && zmodload zsh/zprof
      export LANG=en_US.UTF-8

      # tmux autostart
      if [[ -z $TMUX && -z $ZED_TERM && -z $ZPROF && $- == *i* ]]; then
        exec tmux new-session -A -s main
      fi

      source "${zsh-defer}"

      # Completion search path. Earlier entries win; $fpath already holds the
      # per-profile site-functions added at the top of this file.
      fpath=(
        ${config.home.homeDirectory}/.zfunc
        /opt/homebrew/share/zsh/site-functions
        ${config.home.homeDirectory}/.nix-profile/share/zsh/site-functions
        ${config.home.homeDirectory}/.bun
        ${zsh-completions}
        $fpath
      )

      autoload -Uz compinit
      () {
        emulate -L zsh
        setopt extended_glob
        # A full compinit walks every fpath entry and rewrites the dump, which
        # costs ~800ms here; reusing the dump with -C costs ~64ms. Rebuild at
        # most once a day.
        if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
          compinit
        else
          compinit -C
        fi
      }

      # Everything below only matters once the first prompt is up, so keep it
      # off the critical path. Order matches registration order.
      zsh-defer source "${zsh-autosuggestions}"
      zsh-defer source "${zsh-syntax-highlighting}"
      [[ -r ${config.home.homeDirectory}/.credentials/credentials.sh ]] \
        && zsh-defer source ${config.home.homeDirectory}/.credentials/credentials.sh
      zsh-defer -c 'export JAVA_HOME=$(/usr/libexec/java_home -v 25)'
      zsh-defer -c 'eval "$(tv init zsh)"'
    '';

    envExtra = ''
      export XDG_CONFIG_HOME="$HOME/.config"
      export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

      export HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
      export HOMEBREW_REPOSITORY="/opt/homebrew"
      export MANPATH="/opt/homebrew/share/man''${MANPATH+:$MANPATH}:"
      export INFOPATH="/opt/homebrew/share/info:''${INFOPATH:-}"

      path=(
        /opt/homebrew/bin(N-/)
        /opt/homebrew/sbin(N-/)
        /opt/homebrew/opt/openjdk/bin(N-/)
        /opt/homebrew/opt/make/libexec/gnubin(N-/)
        /opt/homebrew/opt/gnu-sed/libexec/gnubin(N-/)
        /opt/homebrew/opt/findutils/libexec/gnubin(N-/)
        $HOME/.local/bin(N-/)
        /usr/local/flutter/bin(N-/)
        $HOME/.cargo/bin(N-/)
        $path
      )
    '';

    # siteFunctions is auto-loaded via `autoload -Uz`
    siteFunctions.gotestcov = ''
      TMPDIR=$(mktemp -d)
      PROFILE_OUT="''${TMPDIR}/cover.out"
      HTML_OUT="''${TMPDIR}/cover.html"
      chmod +w ''${TMPDIR}
      go test -shuffle on -race -v -cover -coverprofile=''${PROFILE_OUT} -p 1 $1 \
      && go tool cover -html=''${PROFILE_OUT} -o ''${HTML_OUT} \
      && open ''${HTML_OUT}
    '';
  };
}
