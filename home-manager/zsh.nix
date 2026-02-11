{ ... }:

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
      sk = ''sk --preview="bat {} --color=always"'';
      matumoto = ''echo "Hello, I am matumoto!"'';
    };

    initContent = ''
      export LANG=en_US.UTF-8
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(tv init zsh)"

      # tmux autostart
      if [[ -z $TMUX && -z $ZED_TERM ]]; then
        ID="$(tmux list-sessions)"
        if [[ -z "$ID" ]]; then
          tmux new-session
        fi
        ID="$ID\nCreate New Session"
        ID="$(echo $ID | sk | cut -d: -f1)"
        if [[ "$ID" = "Create New Session" ]]; then
          tmux new-session
        elif [[ -n "$ID" ]]; then
          tmux attach-session -t "$ID"
        else
          :
        fi
      fi
    '';

    envExtra = ''
      export JAVA_HOME=$(/usr/libexec/java_home -v 25)
      export XDG_CONFIG_HOME="$HOME/.config"
      export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

      path=(
        /opt/homebrew/opt/openjdk/bin(N-/)
        /opt/homebrew/opt/make/libexec/gnubin(N-/)
        /opt/homebrew/opt/gnu-sed/libexec/gnubin(N-/)
        /opt/homebrew/opt/findutils/libexec/gnubin(N-/)
        $HOME/.local/bin(N-/)
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
