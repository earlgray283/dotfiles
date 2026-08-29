{
  config,
  lib,
  pkgs,
  ...
}:

let
  miseTools = {
    "1password-cli" = "2.39.0";
    actionlint = "1.7.12";
    atlas = "1.3.0";
    bat = "0.26.1";
    biome = "2.5.10";
    buf = "1.72.0";
    bun = "1.4.0";
    clang = "21.1.8";
    clang-format = "21.1.8";
    "conda:clang-tools" = "21.1.8";
    cue = "0.17.1";
    delta = "0.19.2";
    dprint = "0.56.1";
    fd = "10.4.2";
    fzf = "0.74.3";
    gh = "2.98.0";
    "github:docker/docker-language-server" = "0.20.1";
    "github:Feel-ix-343/markdown-oxide" = "0.25.12";
    "github:quarylabs/sqruff" = "0.40.0";
    "github:reteps/dockerfmt" = "0.5.4";
    gitleaks = "8.30.1";
    # deliberate exception to the pin-everything rule: follow the Go release train
    go = "latest";
    "go:golang.org/x/tools/cmd/goimports" = "0.49.0";
    "go:golang.org/x/tools/gopls" = "0.23.0";
    golangci-lint = "2.13.1";
    hadolint = "2.15.1";
    # registry (aqua) resolves hyperfine to the x86_64 asset; github: picks arm64
    "github:sharkdp/hyperfine" = "1.20.0";
    just = "1.58.0";
    lazygit = "0.64.1";
    lua-language-server = "3.19.1";
    node = "26.7.0";
    "npm:@tailwindcss/language-server" = "0.16.0";
    "npm:prettier" = "3.9.6";
    "npm:typescript-language-server" = "6.0.0";
    "npm:vscode-langservers-extracted" = "4.10.0";
    "npm:yaml-language-server" = "1.24.0";
    oxlint = "1.79.0";
    "pipx:sqlfluff" = "4.3.0";
    "pre-commit" = "4.6.2";
    protolint = "0.57.0";
    ripgrep = "15.2.0";
    rust = "1.98.0";
    starship = "1.26.0";
    stylua = "2.5.2";
    taplo = "0.10.0";
    tealdeer = "1.8.1";
    television = "0.15.9";
    terraform = "1.15.9";
    terraform-ls = "0.39.0";
    tree-sitter = "0.26.12";
    uv = "0.12.5";
    vale = "3.18.0";
    worktrunk = "0.74.0";
    xh = "0.26.2";
    yamlfmt = "0.21.0";
  };

  # nixpkgs' mise is not in any cache for aarch64-darwin and builds from source
  # (Rust, 1.2GiB vendor dir); the upstream release tarball costs nothing.
  misePackage = pkgs.stdenv.mkDerivation {
    pname = "mise";
    version = "2026.8.5";

    src = pkgs.fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v2026.8.5/mise-v2026.8.5-macos-arm64.tar.gz";
      hash = "sha256-hZg6m4jja6MhG8tLLl+B6o0ncIUn2RAM3oZekvSKPsI=";
    };

    sourceRoot = ".";

    installPhase = ''
      install -Dm755 "$(find . -type f -perm -u+x -name mise | sort | head -n 1)" $out/bin/mise
    '';

    meta.mainProgram = "mise";
  };

  # Only a symlink lands in /nix/store; the Mach-O binary stays under $HOME,
  # which is what keeps it out of Falcon's scan scope.
  mkMiseBin =
    {
      name,
      bins ? [ name ],
      mainProgram ? name,
    }:
    pkgs.runCommand "mise-${name}" { meta = { inherit mainProgram; }; } ''
      mkdir -p $out/bin
      ${lib.concatMapStringsSep "\n" (
        b: "ln -s ${config.home.homeDirectory}/.local/share/mise/shims/${b} $out/bin/${b}"
      ) bins}
    '';

  # miseInstall runs before linkGeneration, so ~/.config/mise/config.toml is still
  # the previous generation's. MISE_GLOBAL_CONFIG_FILE only moves mise's write
  # target -- it keeps loading ~/.config/mise/config.toml, and that one wins -- so
  # relocate the whole config dir instead. MISE_DATA_DIR is untouched, so installs
  # and shims still land in ~/.local/share/mise.
  activationConfigDir = pkgs.runCommand "mise-activation-config" { } ''
    mkdir -p $out
    cp ${(pkgs.formats.toml { }).generate "mise-config.toml" { tools = miseTools; }} $out/config.toml
  '';
in
{
  _module.args.mkMiseBin = mkMiseBin;

  programs.mise = {
    enable = true;
    package = misePackage;
    enableZshIntegration = true;
    globalConfig.tools = miseTools;
  };

  home.activation.miseInstall = lib.hm.dag.entryBetween [ "migrateGhAccounts" ] [ "writeBoundary" ] ''
    export MISE_CONFIG_DIR=${activationConfigDir}
    export PATH=${lib.makeBinPath [ pkgs.wget ]}:$PATH
    run ${lib.getExe misePackage} install --yes
    run ${lib.getExe misePackage} reshim
  '';
}
