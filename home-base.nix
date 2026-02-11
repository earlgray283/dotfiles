{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Allow unfree packages (e.g., terraform)
  nixpkgs.config.allowUnfree = true;

  # Enable claude-code overlay
  nixpkgs.overlays = [ inputs.claude-code-nix.overlays.default ];

  home.username = "earlgray";
  home.homeDirectory = "/Users/earlgray";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = [
    # Shell/Terminal Tools
    pkgs.fd # Modern find alternative
    pkgs.bat # cat with syntax highlighting
    pkgs.ripgrep # Fast grep alternative
    pkgs.eza # Modern ls alternative (cargo:eza)
    pkgs.delta # git diff viewer
    pkgs.starship # Shell prompt
    pkgs.direnv # Environment switcher
    pkgs.tmux # Terminal multiplexer
    pkgs.skim # Fuzzy finder (github:skim-rs/skim)
    pkgs.tealdeer # tldr client (github:tealdeer-rs/tealdeer)
    pkgs.xh # HTTP client
    pkgs.topgrade # System updater (github:topgrade-rs/topgrade)
    pkgs.television

    # Git Tools
    pkgs.lazygit # Git TUI
    pkgs.gh # GitHub CLI
    pkgs.gitleaks # Secret scanner
    pkgs.pre-commit # Git hooks framework

    # Dotfiles Management
    pkgs.chezmoi

    # Editors
    pkgs.neovim

    # Go Development
    pkgs.go
    pkgs.gopls
    pkgs.gotools # Go tools including goimports
    pkgs.golangci-lint

    # Rust Development
    pkgs.rustc # Rust compiler
    pkgs.cargo # Rust package manager

    # Python Development
    pkgs.uv # Python package manager

    # Lua Development
    pkgs.lua
    pkgs.lua-language-server
    pkgs.stylua # Lua formatter
    pkgs.luarocks # Lua package manager

    # JavaScript/TypeScript/Node Development
    pkgs.nodejs
    pkgs.bun
    pkgs.deno
    pkgs.typescript-language-server
    pkgs.vtsls # TypeScript Language Server
    pkgs.tailwindcss-language-server # Tailwind CSS LSP (npm:@tailwindcss/language-server)

    # nix
    pkgs.nil # Nix Language Server
    pkgs.nixd # Nix Language Server
    pkgs.nixfmt

    # Web Development
    pkgs.biome # Web dev toolchain (formatter/linter)
    pkgs.dprint # Code formatter

    # YAML
    pkgs.yamlfmt # YAML formatter
    pkgs.yaml-language-server # YAML Language Server

    # TOML
    pkgs.taplo # TOML toolkit

    # Markdown
    pkgs.markdown-oxide # Markdown LSP (github:Feel-ix-343/markdown-oxide)

    # Protocol Buffers
    pkgs.buf # Protocol Buffers tool
    pkgs.protolint # Protocol Buffers linter

    # Linters/Formatters
    pkgs.actionlint # GitHub Actions linter
    pkgs.vale # Prose linter
    pkgs.hadolint # Dockerfile linter
    # pkgs.oxlint               # Rust-based fast linter (npm:oxlint) - 要確認

    # Language Servers
    pkgs.docker-language-server

    # Infrastructure/DevOps
    pkgs.terraform
    pkgs.terraform-ls # Terraform language server
    pkgs.atlas # Database schema manager
    # pkgs.cockroachdb            # Linux only - not available on macOS
    pkgs.google-cloud-sdk
    pkgs._1password-cli # 1Password CLI

    # SQL
    pkgs.sqruff # SQL linter

    # Code Tools
    pkgs.tree-sitter
    pkgs.just

    # AI/Other Tools
    (pkgs.claude-code-bun.override { bunBinName = "claude"; }) # Claude Code CLI (Bun runtime)
  ];

  home.file = { };

  home.sessionVariables = { };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    ignores = [
      "**/.claude/settings.local.json"
      ".claude"
      "CLAUDE.md"
      ".mc.json"
      "AGENTS.md"
      ".serena"
      ".mcp.json"
      ".zed"
      ".vscode"
      ".DS_Store"
    ];
    signing = {
      # signing.key is defined in home-personal.nix or home-work.nix
      signByDefault = true;
      format = "ssh";
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
    settings = {
      user = {
        name = "earlgray";
        email = "earlgray283@gmail.com";
      };
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true; # Use n and N to move between diff sections
        light = false; # Set to true if using a light terminal background
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      alias.lo = "log --oneline";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      url."ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
    };
  };

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
      tldr = "tealdeer";
      matumoto = ''echo "Hello, I am matumoto!"'';
    };

    initContent = ''
      export LANG=en_US.UTF-8
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(mise activate zsh)"
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

      [[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
    '';

    envExtra = ''
      export JAVA_HOME=$(/usr/libexec/java_home -v 25)
      export XDG_CONFIG_HOME="$HOME/.config"
      export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      eval "$(mise env -s zsh)"

      path=(
        /opt/homebrew/opt/openjdk/bin(N-/)
        /opt/homebrew/opt/make/libexec/gnubin(N-/)
        /opt/homebrew/opt/gnu-sed/libexec/gnubin(N-/)
        /opt/homebrew/opt/findutils/libexec/gnubin(N-/)
        $HOME/.local/bin(N-/)
        $path
      )
    '';
  };

  # siteFunctions is auto-loaded via `autoload -Uz`
  programs.zsh.siteFunctions.gotestcov = ''
    TMPDIR=$(mktemp -d)
    PROFILE_OUT="''${TMPDIR}/cover.out"
    HTML_OUT="''${TMPDIR}/cover.html"
    chmod +w ''${TMPDIR}
    go test -shuffle on -race -v -cover -coverprofile=''${PROFILE_OUT} -p 1 $1 \
    && go tool cover -html=''${PROFILE_OUT} -o ''${HTML_OUT} \
    && open ''${HTML_OUT}
  '';

  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";

      aws.symbol = "  ";
      buf.symbol = " ";
      bun.symbol = " ";
      c.symbol = " ";

      character = {
        success_symbol = "[\\$](bold fg:#99b7dc)";
        error_symbol = "[\\$](bold red)";
      };

      cpp.symbol = " ";
      cmake.symbol = " ";
      conda.symbol = " ";
      crystal.symbol = " ";
      dart.symbol = " ";
      deno.symbol = " ";

      directory = {
        read_only = " 󰌾";
        fish_style_pwd_dir_length = 1;
        format = "[$path [$read_only](bg:#99b7dc fg:red)](fg:#fffafa bg:#99b7dc)[](fg:#99b7dc) ";
      };

      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      fennel.symbol = " ";
      fossil_branch.symbol = " ";

      gcloud = {
        disabled = true;
        symbol = "  ";
      };

      git_branch.symbol = " ";
      git_commit.tag_symbol = "  ";
      golang.symbol = " ";
      guix_shell.symbol = " ";
      haskell.symbol = " ";
      haxe.symbol = " ";
      hg_branch.symbol = " ";
      hostname.ssh_symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      kotlin.symbol = " ";
      lua.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      meson.symbol = "󰔷 ";
      nim.symbol = "󰆥 ";
      nix_shell.symbol = " ";
      nodejs.symbol = " ";
      ocaml.symbol = " ";

      os.symbols = {
        Alpaquita = " ";
        Alpine = " ";
        AlmaLinux = " ";
        Amazon = " ";
        Android = " ";
        Arch = " ";
        Artix = " ";
        CachyOS = " ";
        CentOS = " ";
        Debian = " ";
        DragonFly = " ";
        Emscripten = " ";
        EndeavourOS = " ";
        Fedora = " ";
        FreeBSD = " ";
        Garuda = "󰛓 ";
        Gentoo = " ";
        HardenedBSD = "󰞌 ";
        Illumos = "󰈸 ";
        Kali = " ";
        Linux = " ";
        Mabox = " ";
        Macos = " ";
        Manjaro = " ";
        Mariner = " ";
        MidnightBSD = " ";
        Mint = " ";
        NetBSD = " ";
        NixOS = " ";
        Nobara = " ";
        OpenBSD = "󰈺 ";
        openSUSE = " ";
        OracleLinux = "󰌷 ";
        Pop = " ";
        Raspbian = " ";
        Redhat = " ";
        RedHatEnterprise = " ";
        RockyLinux = " ";
        Redox = "󰀘 ";
        Solus = "󰠳 ";
        SUSE = " ";
        Ubuntu = " ";
        Unknown = " ";
        Void = " ";
        Windows = "󰍲 ";
      };

      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      pijul_channel.symbol = " ";
      pixi.symbol = "󰏗 ";
      python.symbol = " ";
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      rust.symbol = "󱘗 ";
      scala.symbol = " ";
      swift.symbol = " ";
      zig.symbol = " ";
      gradle.symbol = " ";
    };
  };
  programs.direnv.enable = true;

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
        "zsh-defer".github = "romkatv/zsh-defer";
        "zsh-completions".github = "zsh-users/zsh-completions";
        "zsh-autosuggestions".github = "zsh-users/zsh-autosuggestions";
        "zsh-syntax-highlighting".github = "zsh-users/zsh-syntax-highlighting";
        zfunc = {
          local = "${config.home.homeDirectory}/.zfunc";
          apply = [ "fpath" ];
          use = [ "_*" ];
        };
        "site-functions" = {
          local = "/opt/homebrew/share/zsh/site-functions";
          apply = [ "fpath" ];
        };
        "gcloud-zsh-completion" = {
          local = "${config.home.homeDirectory}/.local/share/mise/installs/gcloud/latest/";
          use = [
            "completion.zsh.inc"
            "path.zsh.inc"
          ];
          apply = [ "source" ];
        };
        "bun-completion" = {
          local = "${config.home.homeDirectory}/.bun";
          use = [ "_bun" ];
          apply = [ "fpath" ];
        };
        compinit.inline = "autoload -Uz compinit && compinit";
        credentials = {
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
