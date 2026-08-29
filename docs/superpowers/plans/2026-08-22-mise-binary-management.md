# mise によるバイナリ管理への移行 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 実行ファイルの実体を `/nix/store` から `~/.local/share/mise/installs/` へ移し、`bin2nix` / `packages/` を廃止する。あわせて、洗い出しの過程で見つかった neovim の参照ずれ（有効なのに未インストールの LSP が 4 つ、インストール済みなのに未有効の LSP が 3 つ）を解消する。

**Architecture:** Nix の attrset 1 つをツール宣言の単一ソースとし、そこから (1) `programs.mise.globalConfig.tools`、(2) activation 用の TOML の 2 つを生成する。`programs.*.package` を要求する 2 モジュール（gh / starship）へは、mise の shim を指すシンボリックリンクだけを含む派生物を渡す。通常の PATH は `mise activate zsh` が供給する。

**Tech Stack:** Nix flakes, home-manager, mise 2026.8.5（`aqua:` / `core:` / `github:` / `npm:` バックエンド）

設計の根拠は `docs/superpowers/specs/2026-08-22-mise-binary-management-design.md` を参照。

## Global Constraints

- 対象プロファイルは home-manager の `earlgray` のみ。nix-darwin 側は変更しない
- バージョンは**すべて完全固定**で書く。`latest` は使わない
- 固定値は「移行前に入っていたバージョン」に合わせる。この移行でツールを上げない。アップグレードは移行後に `mise outdated` で別 PR にする
  - 例外 1: `atlas` は mise の aqua レジストリにマイナー単位のタグしか無いため 1.2.3 → 1.3.0（Task 3）
  - 例外 2: `goimports` `prettier` `vscode-langservers-extracted` は移行前に入っていないので、合わせる相手が無く検証済みの版を使う（Task 5）
- `ubi:` バックエンドは使わない（非推奨、mise 2027.1.0 で削除）。`github:` を使う
- Nix ファイルの整形は `just fmt`（treefmt / nixfmt）。未使用式の検出は `just lint`（deadnix）
- 設定ファイルを追加したら **`git add` してからビルドする**。Nix は git 管理下のファイルしか参照しない
- 各タスクの検証は `home-manager build --flake .#earlgray`。`switch` は Task 10 まで実行しない
- attrset はアルファベット順にソートされる。順序を保ちたい箇所ではリストを使う

---

### Task 1: `mkMiseBin` を追加して gh / starship を差し替える

移行の要となる仕組みを、いちばん小さい形で先に通す。この時点ではまだ `packages/` は残っており、gh と starship だけが mise 経由になる。

**Files:**
- Create: `home-manager/mise.nix`
- Modify: `home-manager/base.nix`（`imports` に 1 行追加、`home.packages` から `localPackages.mise` と `localPackages.aqua` を削除）
- Modify: `home-manager/gh.nix`
- Modify: `home-manager/starship.nix`

**Interfaces:**
- Produces: `home-manager/mise.nix` が `_module.args.mkMiseBin` を定義する。シグネチャは
  `{ name, bins ? [ name ], mainProgram ? name } -> derivation`。
  出力は `$out/bin/<b>` が `~/.local/share/mise/shims/<b>` を指すシンボリックリンクのみ。
- Produces: `programs.mise.enable = true` と `enableZshIntegration = true`。
- Consumes: なし。

- [ ] **Step 1: `home-manager/mise.nix` を作る**

この段階では `globalConfig.tools` に gh と starship だけを入れる。バージョンは移行前の
`packages/gh.nix` / `packages/starship.nix` に書かれている値に合わせる。

```nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  miseTools = {
    gh = "2.97.0";
    starship = "1.26.0";
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

  # home.activation runs before linkGeneration, so ~/.config/mise/config.toml
  # does not exist yet; hand mise this copy via MISE_GLOBAL_CONFIG_FILE.
  activationConfig = (pkgs.formats.toml { }).generate "mise-activation.toml" {
    tools = miseTools;
  };
in
{
  _module.args.mkMiseBin = mkMiseBin;

  programs.mise = {
    enable = true;
    package = pkgs.mise;
    enableZshIntegration = true;
    globalConfig.tools = miseTools;
  };

  home.activation.miseInstall = lib.hm.dag.entryBetween [ "migrateGhAccounts" ] [ "writeBoundary" ] ''
    export MISE_GLOBAL_CONFIG_FILE=${activationConfig}
    run ${lib.getExe pkgs.mise} install --yes
    run ${lib.getExe pkgs.mise} reshim
  '';
}
```

- [ ] **Step 2: `home-manager/base.nix` の `imports` に追加する**

`./mcp.nix` の下に `./mise.nix` を足す。

```nix
    ./mcp.nix
    ./mise.nix
    ./direnv.nix
```

- [ ] **Step 3: `home-manager/base.nix` の `home.packages` から 2 行を削除する**

`localPackages.mise` は `programs.mise.package` が入れるので重複する。`localPackages.aqua` は
mise の aqua バックエンドが内蔵なので不要。ファイル末尾付近の該当ブロックを次のようにする。

```nix
    localPackages.hyperfine
    pkgs.wget
```

- [ ] **Step 4: `home-manager/gh.nix` を差し替える**

```nix
{ pkgs, mkMiseBin, ... }:

{
  programs.gh = {
    enable = true;
    package = mkMiseBin { name = "gh"; };
    extensions = [ pkgs.gh-poi ];
  };
}
```

- [ ] **Step 5: `home-manager/starship.nix` の 1 行目と `package` を差し替える**

1 行目を `{ mkMiseBin, ... }:` に、`package = localPackages.starship;` を
`package = mkMiseBin { name = "starship"; };` にする。`settings` は触らない。

- [ ] **Step 6: git に追加して整形・ビルドする**

```bash
git add home-manager/mise.nix home-manager/base.nix home-manager/gh.nix home-manager/starship.nix
just fmt
just lint
home-manager build --flake .#earlgray
```

期待: ビルド成功。`pkgs.buildEnv warning: creating dangling symlink ... -> /Users/earlgray/.local/share/mise/shims/gh` という警告が出るが、これは正常（`mise install` 前なので shim がまだ無い）。

- [ ] **Step 7: activation の順序を検証する**

生成された activation スクリプトの中で `miseInstall` が `migrateGhAccounts` より前にあることを確認する。

```bash
rg -n "miseInstall|migrateGhAccounts" result/activate
```

期待: `miseInstall` の行番号が `migrateGhAccounts` より小さい。逆なら `entryBetween` の
第 1 引数（before）と第 2 引数（after）を取り違えているので直す。

- [ ] **Step 8: コミット**

```bash
git add -A
git commit -m "home-manager: route gh and starship through mise shims

mkMiseBin emits a derivation whose only content is a symlink into
~/.local/share/mise/shims, so the executable itself never lands in
/nix/store."
```

---

### Task 2: bin2nix 由来の 23 ツールを mise へ移す

Task 1 で仕組みが通ったので、残る bin2nix 管理ツールをまとめて移す。バージョンは
`packages/*.nix` の現在値をそのまま持ってくる（移行でツールを上げない）。

**Files:**
- Modify: `home-manager/mise.nix`（`miseTools` に 23 エントリ追加）
- Modify: `home-manager/base.nix`（`home.packages` から `localPackages.*` を削除、関数引数からも削除）

**Interfaces:**
- Consumes: Task 1 の `miseTools` attrset。
- Produces: `miseTools` に bin2nix 由来の全ツールが入った状態。

- [ ] **Step 1: `miseTools` を次の内容に置き換える**

`packages/codex.nix` と `packages/oxc.nix` は参照されていない（codex は llm-agents overlay、
oxlint は `pkgs.oxlint` 由来）ので含めない。`aqua` と `mise` も Task 1 の理由で含めない。

```nix
  miseTools = {
    actionlint = "1.7.12";
    bat = "0.26.1";
    biome = "2.5.8";
    buf = "1.72.0";
    delta = "0.19.2";
    dprint = "0.55.2";
    fd = "10.4.2";
    fzf = "0.74.2";
    gh = "2.97.0";
    gitleaks = "8.30.1";
    golangci-lint = "2.12.2";
    hyperfine = "1.20.0";
    just = "1.58.0";
    lazygit = "0.64.1";
    protolint = "0.56.4";
    ripgrep = "15.2.0";
    starship = "1.26.0";
    stylua = "2.5.2";
    taplo = "0.10.0";
    television = "0.15.9";
    tree-sitter = "0.26.12";
    uv = "0.12.4";
    vale = "3.17.1";
    worktrunk = "0.73.0";
    xh = "0.26.2";
  };
```

レジストリ名は小文字。`StyLua` ではなく `stylua` である点に注意。

- [ ] **Step 2: `home-manager/base.nix` から `localPackages.*` の行をすべて削除する**

削除対象は 23 行（`localPackages.fd` `bat` `ripgrep` `delta` `fzf` `xh` `television` `just`
`tree-sitter` `lazygit` `gitleaks` `worktrunk` `golangci-lint` `uv` `StyLua` `biome` `dprint`
`actionlint` `taplo` `buf` `protolint` `vale` `hyperfine`）。

あわせて 5 行目の関数引数 `localPackages,` も削除する。残すと deadnix が未使用引数として
検出する。`flake.nix` は Task 7 まで渡し続けるが、モジュールが受け取らないだけなので問題ない。

- [ ] **Step 3: 削除漏れが無いことを確認する**

```bash
rg -n "localPackages" home-manager/base.nix
```

期待: ヒット 0 件。

- [ ] **Step 4: 整形してビルドする**

```bash
just fmt
just lint
home-manager build --flake .#earlgray
```

期待: ビルド成功、deadnix も通る。

- [ ] **Step 5: コミット**

```bash
git add -A
git commit -m "home-manager: move bin2nix tools to mise

Versions match what packages/*.nix pinned, so this changes where the
binaries live without changing which ones run."
```

---

### Task 3: nixpkgs 由来のツールを mise へ移す

**Files:**
- Modify: `home-manager/mise.nix`（`miseTools` に 14 エントリ追加）
- Modify: `home-manager/base.nix`（`home.packages` から 14 行削除）

**Interfaces:**
- Consumes: Task 2 の `miseTools`。
- Produces: レジストリ収載ツールがすべて `miseTools` に入った状態。

- [ ] **Step 1: `miseTools` に次の 14 エントリを追加する**

値は現在の nixpkgs のバージョンに合わせてある。

```nix
    "1password-cli" = "2.34.1";
    atlas = "1.3.0";
    bun = "1.3.13";
    cue = "0.17.1";
    go = "1.26.5";
    hadolint = "2.14.0";
    lua-language-server = "3.18.2";
    node = "24.18.0";
    oxlint = "1.75.0";
    "pre-commit" = "4.5.1";
    tealdeer = "1.8.1";
    terraform = "1.15.8";
    terraform-ls = "0.38.7";
    yamlfmt = "0.21.0";
```

atlas だけは例外で、現在の nixpkgs は 1.2.3 だが mise の aqua レジストリには
マイナー単位のタグ（1.2.0 / 1.3.0）しか無いため 1.3.0 に上げる。

- [ ] **Step 2: `home-manager/base.nix` の `home.packages` から対応する 14 行を削除する**

削除対象: `pkgs.go` `pkgs.nodejs` `pkgs.bun` `pkgs.oxlint` `pkgs.terraform` `pkgs.terraform-ls`
`pkgs.lua-language-server` `pkgs.yamlfmt` `pkgs.hadolint` `pkgs.cue` `pkgs.atlas`
`pkgs.tealdeer` `pkgs.pre-commit` `pkgs._1password-cli`

`pkgs.gopls` と `pkgs.gotools` はこのタスクでは残す。Task 5 で `go:` バックエンドへ移す。

- [ ] **Step 3: 整形してビルドする**

```bash
just fmt
just lint
home-manager build --flake .#earlgray
```

期待: ビルド成功。

- [ ] **Step 4: コミット**

```bash
git add -A
git commit -m "home-manager: move registry-covered nixpkgs tools to mise

atlas goes 1.2.3 -> 1.3.0 because mise's aqua registry only carries
minor tags for it; every other version matches what nixpkgs shipped."
```

---

### Task 4: レジストリ外の 7 ツールを `github:` / `npm:` で移す

**Files:**
- Modify: `home-manager/mise.nix`（`miseTools` に 7 エントリ追加）
- Modify: `home-manager/base.nix`（`home.packages` から 7 行削除）

**Interfaces:**
- Consumes: Task 3 の `miseTools`。
- Produces: `miseTools` が 46 エントリになった状態。

- [ ] **Step 1: `miseTools` に次の 7 エントリを追加する**

キーにコロンが入るので必ずクォートする。

```nix
    "github:Feel-ix-343/markdown-oxide" = "0.25.12";
    "github:docker/docker-language-server" = "0.20.1";
    "github:quarylabs/sqruff" = "0.39.0";
    "github:reteps/dockerfmt" = "0.5.4";
    "npm:@tailwindcss/language-server" = "0.14.29";
    "npm:typescript-language-server" = "5.3.0";
    "npm:yaml-language-server" = "1.24.0";
```

- [ ] **Step 2: `home-manager/base.nix` の `home.packages` から対応する 7 行を削除する**

削除対象: `pkgs.markdown-oxide` `pkgs.docker-language-server` `pkgs.dockerfmt` `pkgs.sqruff`
`pkgs.typescript-language-server` `pkgs.yaml-language-server` `pkgs.tailwindcss-language-server`

- [ ] **Step 3: 整形してビルドする**

```bash
just fmt
just lint
home-manager build --flake .#earlgray
```

期待: ビルド成功。

- [ ] **Step 4: コミット**

```bash
git add -A
git commit -m "home-manager: move remaining LSPs and formatters to mise

These are not in mise's registry, so the backend is spelled out.
github: rather than ubi: — ubi is deprecated as of mise 2027.1.0."
```

---

### Task 5: ソースビルド系と欠けている npm ツールを移す

neovim が起動する linter / formatter / LSP を `/nix` から出しきる。`go:` と `pipx:` は
ソースビルドになるが、実測で 3 つ合わせて 15.6 秒だったので activation に入れて問題ない。

あわせて、参照されているのに入っていなかった `prettier` と
`vscode-langservers-extracted`（`cssls` と `html` の実体）を追加する。

**Files:**
- Modify: `home-manager/mise.nix`（`miseTools` に 5 エントリ追加）
- Modify: `home-manager/base.nix`（`home.packages` から 3 行削除）

**Interfaces:**
- Consumes: Task 4 の `miseTools`（46 エントリ）。
- Produces: `miseTools` が 51 エントリになった状態。Task 6 が参照する shim
  `gopls` `goimports` `sqlfluff` `prettier` `vscode-css-language-server`
  `vscode-html-language-server` が揃う。

- [ ] **Step 1: `miseTools` に次の 5 エントリを追加する**

```nix
    "go:golang.org/x/tools/cmd/goimports" = "0.42.0";
    "go:golang.org/x/tools/gopls" = "0.23.0";
    "npm:prettier" = "3.9.6";
    "npm:vscode-langservers-extracted" = "4.10.0";
    "pipx:sqlfluff" = "4.2.2";
```

`vscode-langservers-extracted` は 1 パッケージで `vscode-css-language-server`
`vscode-html-language-server` `vscode-json-language-server`
`vscode-eslint-language-server` の 4 つを提供する。使うのは前 2 つ。

- [ ] **Step 2: `home-manager/base.nix` の `home.packages` から 3 行を削除する**

削除対象: `pkgs.gopls` / `(lib.lowPrio pkgs.gotools)` / `pkgs.sqlfluff`

`pkgs.gotools` は goimports 以外に `godoc` `deadcode` `present` `play` `callgraph` なども
提供している。conform が使うのは goimports だけで、他は現状どこからも参照されていないため
まとめて落とす。あとで必要になったら `go:` バックエンドで個別に足せる。

削除の結果 `lib` が `base.nix` で未使用になる場合は、関数引数の `lib,` も削除する。

- [ ] **Step 3: 整形してビルドする**

```bash
just fmt
just lint
home-manager build --flake .#earlgray
```

期待: ビルド成功。`lib` が未使用のまま残っていると deadnix が落ちる。

- [ ] **Step 4: コミット**

```bash
git add -A
git commit -m "home-manager: move gopls, goimports and sqlfluff to mise

Source builds turned out to cost 15.6s for all three together, so the
earlier reason for leaving them in /nix does not hold. gopls matters
most: a 30MB process that starts on every Go session.

Also adds prettier and vscode-langservers-extracted, which conform and
vim.lsp.enable reference but nothing installed."
```

---

### Task 6: neovim が参照するツールと入っているツールを揃える

移行対象を洗い出す過程で見つかった既存の不整合を解消する。移行そのものとは独立だが、
Task 5 までで実体が揃ったのでここで直す。

**Files:**
- Modify: `home-manager/neovim/config/lua/plugins/lsp.lua:28-40`

**Interfaces:**
- Consumes: Task 5 の shim 群。
- Produces: なし。

- [ ] **Step 1: `vim.lsp.enable` のリストを差し替える**

`marksman` は入っていないので消し、すでに入っている `markdown_oxide` に切り替える。
`docker_language_server` と `tailwindcss` は実体が入っているのに有効化されていなかったので足す。
`cssls` と `html` は Task 5 で実体が入ったのでそのまま残す。

```lua
      vim.lsp.enable({
        "biome",
        "cssls",
        "docker_language_server",
        "gopls",
        "html",
        "lua_ls",
        "markdown_oxide",
        "nixd",
        "tailwindcss",
        "taplo",
        "terraformls",
        "ts_ls",
        "yamlls",
      })
```

`nvim-lspconfig` 2.11.0 に 5 つすべての定義があること、および各定義が期待する
実行ファイル名が mise の shim 名と一致することは設計時に確認済み。

- [ ] **Step 2: git に追加してビルドする**

```bash
git add home-manager/neovim/config/lua/plugins/lsp.lua
just fmt
just lint
home-manager build --flake .#earlgray
```

期待: ビルド成功。stylua が lsp.lua を整形する。

- [ ] **Step 3: コミット**

```bash
git add -A
git commit -m "neovim: align enabled LSP servers with what is installed

cssls, html and marksman were enabled but never installed, so they had
been silently dead. markdown-oxide, docker-language-server and
tailwindcss-language-server were installed but never enabled.

Markdown goes to markdown_oxide rather than marksman: that is the one
already installed."
```

---

### Task 7: `packages/` と bin2nix の配線を削除する

**Files:**
- Delete: `packages/`（30 ファイル）
- Delete: `config.toml`
- Modify: `flake.nix:109`, `flake.nix:186`

**Interfaces:**
- Consumes: Task 6 の状態（`localPackages` の参照が 1 つも残っていないこと）。
- Produces: `localPackages` が存在しない flake。

- [ ] **Step 1: 参照が残っていないことを確認する**

```bash
rg -n "localPackages" --glob '!packages/**' --glob '!docs/**'
```

期待: `flake.nix` の 2 行（`109` の定義と `186` の受け渡し）だけがヒットする。
`home-manager/` 側にヒットが残っていたら Task 2〜5 の削除漏れなので先に直す。

- [ ] **Step 2: `flake.nix` から 2 行を削除する**

`flake.nix:109` の `localPackages = pkgs.callPackage ./packages { };` を削除し、
`flake.nix:186` の `inherit inputs localPackages;` を `inherit inputs;` にする。

- [ ] **Step 3: ディレクトリとファイルを削除する**

```bash
git rm -r packages config.toml
```

- [ ] **Step 4: 整形してビルドする**

```bash
just fmt
just lint
home-manager build --flake .#earlgray
```

期待: ビルド成功。失敗する場合は `localPackages` の参照が残っている。

- [ ] **Step 5: 両構成をビルドして CI と同じ検証を通す**

```bash
just check
```

期待: `nix flake check` と両構成のビルドが成功する。

- [ ] **Step 6: コミット**

```bash
git add -A
git commit -m "packages: drop bin2nix

mise's aqua and github backends fetch the same GitHub Release artifacts,
so the generated derivations have no remaining consumers."
```

---

### Task 8: `CLAUDE.md` を mise 運用に書き換える

**Files:**
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: Task 7 の状態。
- Produces: なし。

- [ ] **Step 1: 「GitHub Release パッケージの管理（`packages/`）」節をまるごと置き換える**

`bin2nix` の説明・`config.toml` の例・ツールの所在をすべて削除し、次の内容にする。

````markdown
## バイナリの管理（mise）

実行ファイルの実体は `~/.local/share/mise/installs/` に置き、`/nix/store` には入れない。
Falcon がホームディレクトリ配下を除外している一方 `/nix` はスキャンするため。

宣言は `home-manager/mise.nix` の `miseTools` attrset に一元化してある。
`programs.mise.globalConfig.tools` と activation 用 TOML の両方がここから生成される。

```bash
# 更新可能なツールを一覧する
mise outdated

# バージョンを上げる場合は miseTools の値を書き換えてから
home-manager build --flake .#earlgray
just switch-home-manager
```

### 注意点

- バージョンは**完全固定**で書く。`latest` は使わない
- `ubi:` バックエンドは使わない（mise 2027.1.0 で削除予定）。`github:` を使う
- `programs.*.package` を要求するモジュールには `mkMiseBin` を渡す
  （現在は `home-manager/gh.nix` と `home-manager/starship.nix`）
- mise 自身は `/nix` に残る。home-manager が**ビルド時**に `mise completion bash` を
  実行するため、実行可能な派生物が必要
````

- [ ] **Step 2: 「Repository Structure」節の 2 行を削除する**

`packages/` と `config.toml` を説明している行を消す。

- [ ] **Step 3: コミット**

```bash
git add CLAUDE.md
git commit -m "docs: describe mise-based binary management in CLAUDE.md"
```

---

### Task 9: 検証スクリプトを追加する

`switch` の前に、mise 管理下の実行ファイルがすべて `/nix` の外に解決されることを
確かめる手段を用意する。

**Files:**
- Modify: `justfile`

**Interfaces:**
- Consumes: Task 8 の状態。
- Produces: `just verify-mise` タスク。

- [ ] **Step 1: `justfile` に次のタスクを追加する**

シェバンを使う recipe では、行頭に通常のコマンドを混ぜられない。全体を 1 つの
シェバンブロックにする。

```make
# Confirm every tool declared in home-manager/mise.nix resolves outside /nix.
# Run this from an interactive zsh: it checks PATH resolution, and PATH is
# what `mise activate zsh` sets up.
verify-mise:
    #!/usr/bin/env bash
    set -uo pipefail
    mise install --yes
    mise reshim
    fail=0
    for b in actionlint atlas bat biome buf bun cue delta docker-language-server \
             dockerfmt dprint fd fzf gh gitleaks go goimports golangci-lint \
             gopls hadolint hyperfine just lazygit lua-language-server \
             markdown-oxide node op oxlint pre-commit prettier protolint rg \
             sqlfluff sqruff starship stylua tailwindcss-language-server taplo \
             terraform terraform-ls tldr tree-sitter tv \
             typescript-language-server uv vale vscode-css-language-server \
             vscode-html-language-server wt xh yaml-language-server yamlfmt; do
      p=$(command -v "$b" || true)
      if [[ -z $p ]]; then
        echo "MISSING  $b"
        fail=1
      elif [[ $p == /nix/store/* ]]; then
        echo "IN /nix  $b -> $p"
        fail=1
      else
        printf '%-32s %s\n' "$b" "$p"
      fi
    done
    exit $fail
```

リストは 52 個。`miseTools` の 51 エントリのうち
`npm:vscode-langservers-extracted` だけが使う実行ファイルを 2 つ
（`vscode-css-language-server` と `vscode-html-language-server`）提供するため、
51 + 1 で 52 になる。

実行ファイル名がツール名と異なるものは `op`（1password-cli）、`rg`（ripgrep）、
`tv`（television）、`wt`（worktrunk）、`tldr`（tealdeer）、
`goimports`（`go:golang.org/x/tools/cmd/goimports`）、
`gopls`（`go:golang.org/x/tools/gopls`）。
tealdeer が入れる実行ファイルは `tldr` だけなので `tealdeer` は含めない。

- [ ] **Step 2: コミット**

```bash
git add justfile
git commit -m "just: add verify-mise to check every tool resolves outside /nix"
```

---

### Task 10: 適用して動作確認する

ここではじめて `switch` する。ここまでのタスクはすべて `build` 止まりだった。

**Files:** なし（実行のみ）

**Interfaces:**
- Consumes: Task 9 までの全変更。
- Produces: 適用済みの環境。

- [ ] **Step 1: 最終ビルドで差分を確認する**

```bash
home-manager build --flake .#earlgray
nix store diff-closures ~/.local/state/nix/profiles/home-manager result
```

期待: bin2nix 由来のパッケージが消えている。

- [ ] **Step 2: 適用する**

```bash
just switch-home-manager
```

期待: activation 中に `mise install` が走り、51 ツールがダウンロードされる。初回は数分かかる。
うち gopls / goimports / sqlfluff はソースビルドになるが、実測で 3 つ合わせて 15.6 秒だった。
ネットワークが無いと失敗するので、接続を確認してから実行する。

- [ ] **Step 3: 新しいシェルを開いて検証タスクを走らせる**

`mise activate` は新しいシェルからしか効かないので、必ずシェルを開き直す。

```bash
exec zsh
just verify-mise
```

期待: 全行が `~/.local/share/mise/installs/...` を指し、`MISSING` と `IN /nix` が 1 行も出ない。

- [ ] **Step 4: gh と starship が mise 経由で動いていることを確認する**

```bash
gh --version
readlink -f "$(command -v starship)"
rg -o '/nix/store/[^ "]*mise-starship[^ "]*' ~/.zshrc
readlink -f "$(rg -o -m1 '/nix/store/[^ "]*mise-starship[^ "]*/bin/starship' ~/.zshrc)"
```

期待: `gh` がバージョンを表示する。`starship` の実体が `~/.local/share/mise/installs/` 配下を指す。

`.zshrc` には `/nix/store/...-mise-starship/bin/starship` という store パスが**残っているのが正常**。
これは `mkMiseBin` が作ったシンボリックリンクであってバイナリではない。4 行目の `readlink -f` が
`~/.local/share/mise/installs/starship/1.26.0/starship` を返せば、実体がホーム配下にあると確認できる。

- [ ] **Step 5: neovim が起動するツールの解決先を確認する**

```bash
nvim --headless '+lua for _,b in ipairs({"gopls","goimports","stylua","biome","sqlfluff","prettier","vscode-css-language-server","vscode-html-language-server","markdown-oxide","docker-language-server","tailwindcss-language-server","nixd"}) do print(b, vim.fn.exepath(b)) end' +qa
```

期待: `nixd` だけが `/nix/store` 配下（Nix 自身の LSP なので正しい）。
残り 11 個はすべて `~/.local/share/mise/installs/` 配下を指し、空文字のものが 1 つも無い。
空文字が出たら Task 5 の `miseTools` か Task 9 の `mise reshim` が漏れている。

```bash
nvim home-manager/neovim/config/lua/plugins/conform.lua
```

期待: lua_ls が起動し、保存で stylua が走る。

- [ ] **Step 6: 起動時間の退行が無いことを測る**

```bash
hyperfine -w 3 -r 20 'zsh -i -c exit'
```

期待: `mise activate` と starship init の分だけ増えるが、体感できる退行（+100ms 超）は無い。
超えている場合は `mise activate` ではなく shims が PATH に入っていないか確認する。

- [ ] **Step 7: 検証中に見つかった修正をコミットする**

問題が無ければコミットするものは無い。あれば個別に修正してコミットする。

- [ ] **Step 8: PR を出す**

```bash
git push -u origin design/mise-binary-management
gh pr create --title "バイナリ管理を bin2nix から mise へ移す" --body "$(cat <<'EOF'
## 背景

Falcon がホームディレクトリ配下を除外する一方 `/nix` をスキャンするため、
実行ファイルの実体を `~/.local/share/mise/installs/` へ移す。

## 変更

- `home-manager/mise.nix` を新設。`miseTools` attrset を宣言の単一ソースとし、
  `programs.mise.globalConfig.tools` と activation 用 TOML の両方を生成する
- `mkMiseBin` で mise の shim を指すシンボリックリンクだけの派生物を作り、
  `programs.gh.package` と `programs.starship.package` に渡す
- 51 ツールを mise へ移し、`packages/`・`config.toml`・bin2nix を削除
- neovim が参照する LSP と、実際に入っているツールのずれを解消
  （`cssls` `html` `marksman` は有効なのに未インストール、`markdown-oxide`
  `docker-language-server` `tailwindcss-language-server` はインストール済みなのに未有効だった）
- `just verify-mise` で 52 個の実行ファイルが `/nix` の外に解決されることを確認できる

## 残るもの

mise 自身（home-manager がビルド時に `mise completion bash` を実行するため）、
Nix ツールチェーン、`eza`（cargo バックエンドのみ）、overlay 由来の LLM エージェント群。

neovim が起動する linter / formatter / LSP で `/nix` に残るのは
`nixd` `nixfmt` `nix` `clang-format` と rust 系だけで、いずれも Nix 自身か
フォールバック経路なので `/nix` にあるのが正しい。

設計は `docs/superpowers/specs/2026-08-22-mise-binary-management-design.md`。

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## ロールバック

`git revert` して `home-manager switch` すれば `/nix` 側の構成に戻る。
`~/.local/share/mise/installs/` は残るが PATH から外れるだけで無害。
不要なら `mise prune` で消す。
