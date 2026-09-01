{
  pkgs,
  config,
  lib,
  ...
}:

{
  home.packages = [ pkgs.zsh-completions ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/mise/shims"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/opt/homebrew/opt/openjdk/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    XDG_CONFIG_HOME = config.xdg.configHome;
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew";
    MANPATH = "/opt/homebrew/share/man\${MANPATH+:$MANPATH}:";
    INFOPATH = "/opt/homebrew/share/info:\${INFOPATH:-}";
    JAVA_HOME = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home";
  };

  programs.zsh = {
    enable = true;
    envExtra = "export NOSYSZSHRC=1";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.ignoreAllDups = true; # setopt HIST_IGNORE_ALL_DUPS

    setOptions = [
      "INTERACTIVE_COMMENTS" # Allow comments in interactive shell
    ];

    shellAliases = {
      ls = "eza --icons=auto";
      fd = "fd -I";
      mv = "mv -v";
      gitroot = "cd \"$(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)\"";
      sed = lib.getExe pkgs.gnused;
      xargs = "${lib.getBin pkgs.findutils}/bin/xargs";
    };

    completionInit = ''
      fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
      autoload -Uz compinit
      () {
        emulate -L zsh
        setopt extended_glob
        # Rebuild a stale completion dump at most once a day.
        if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
          compinit
        else
          compinit -C
        fi
      }
    '';

    # siteFunctions is auto-loaded via `autoload -Uz`
    siteFunctions.gotestcov = ''
      local tmpdir profile_out html_out
      tmpdir=$(mktemp -d) || return
      profile_out=$tmpdir/cover.out
      html_out=$tmpdir/cover.html
      go test -shuffle on -race -v -coverprofile="$profile_out" -p 1 "''${1:-.}" \
      && go tool cover -html="$profile_out" -o "$html_out" \
      && open "$html_out"
    '';
  };
}
