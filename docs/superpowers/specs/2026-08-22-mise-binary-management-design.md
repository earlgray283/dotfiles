# バイナリ管理を bin2nix から mise へ移す

作成日: 2026-08-22

## 背景

CrowdStrike Falcon が動いている環境では `/nix` 配下がスキャン対象に入る。
ホームディレクトリ配下は IT のポリシーで除外設定されているため、実行ファイルの実体を
`/nix/store` から `~/.local/share/mise/installs/` へ移せばスキャンを回避できる。

現状 `packages/` 配下の 29 個の Nix 派生物が `bin2nix` によって生成されており、
これらは GitHub Release のプリビルドバイナリを取得しているだけである。
mise の `aqua:` / `github:` バックエンドはこれと同じことをするので、機能的に等価な置き換えになる。

## 目的

- `home.packages` および `programs.*.package` で参照するバイナリの実体を `/nix/store` の外へ出す
- 「どのツールをどのバージョンで入れるか」の宣言は dotfiles（Nix）側に残す
- `bin2nix` / `packages/` / ルートの `config.toml` を廃止する

## 非目標

- `/nix` を完全に空にすること。mise 自身と Nix ツールチェーンは `/nix` に残る
- mise 側でチェックサム検証を行うこと（後述の制約を参照）
- Falcon の除外設定そのものの変更

## 設計

### 役割分担

| 役割 | 担当 |
|---|---|
| ツールとバージョンの宣言 | Nix の `miseTools` attrset（単一ソース） |
| mise への宣言の受け渡し | `programs.mise.globalConfig.tools` |
| 実体の配置 | mise → `~/.local/share/mise/installs/` |
| `programs.*.package` への供給 | `mkMiseBin`（symlink のみの派生物） |
| 通常利用時の PATH | `mise activate zsh` |
| インストールの実行 | `home.activation.miseInstall` |

### `mkMiseBin`

`programs.gh.package` / `programs.starship.package` に渡すための派生物を作る。
出力に含まれるのは `~/.local/share/mise/shims/<bin>` を指すシンボリックリンクだけで、
Mach-O バイナリは `/nix/store` に入らない。

```nix
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
```

適用先は 2 箇所のみ。

- `home-manager/gh.nix`: `package = mkMiseBin { name = "gh"; }`
- `home-manager/starship.nix`: `package = mkMiseBin { name = "starship"; }`

他のツールは `home.packages` から削除し、`mise activate` が通す PATH に任せる。
`git.nix` の `pager = "delta"` のように名前だけで参照している箇所は変更不要。

### 宣言の単一ソース

`home-manager/mise.nix` に attrset を 1 つ置き、2 箇所から参照する。

```nix
miseTools = {
  fd = "10.4.2";
  ripgrep = "14.1.1";
  "github:Feel-ix-343/markdown-oxide" = "0.25.12";
  "npm:typescript-language-server" = "5.3.0";
  # ...
};
```

バージョンは**完全固定**で書く。`latest` は使わない。

- `programs.mise.globalConfig.tools = miseTools;` → `~/.config/mise/config.toml`（store への読み取り専用シンボリックリンク）
- `(pkgs.formats.toml { }).generate "mise-activation.toml" { tools = miseTools; }` → activation 時に使う設定ファイル

後者が必要な理由は次節。

### activation の順序

Home Manager の gh モジュールは activation 中に `gh help` を実行する
（`modules/programs/gh.nix:172` の `migrateGhAccounts`、`entryBetween ["linkGeneration"] ["writeBoundary"]`）。
このときシンボリックリンク先の shim が存在していないと失敗する。
したがって `mise install` はそれより前に走らせる必要がある。

ところが `linkGeneration` より前なので、`~/.config/mise/config.toml` はまだ張られていない。
そこで activation 専用に生成した TOML を `MISE_GLOBAL_CONFIG_FILE` で明示的に渡す。

```nix
home.activation.miseInstall =
  lib.hm.dag.entryBetween [ "migrateGhAccounts" ] [ "writeBoundary" ] ''
    export MISE_GLOBAL_CONFIG_FILE=${miseActivationConfig}
    run ${lib.getExe pkgs.mise} install --yes
    run ${lib.getExe pkgs.mise} reshim
  '';
```

`mise install` はネットワークを必要とする。オフライン時は activation が失敗するが、
中途半端に成功して PATH に壊れたリンクが残るより明示的に失敗させるほうがよいので、
エラーは握り潰さない。

### PATH

`programs.mise.enableZshIntegration = true`（`mise activate zsh`）のみを使う。
shims ディレクトリは `mkMiseBin` が参照するために存在させるが、PATH には入れない。

`activate` は実パスを PATH に入れるためオーバーヘッドがない。shims 経由は 1 exec あたり
+8.7ms のコストがあり、`rg` / `fd` を大量に起動する neovim では体感に出る。

既知の制約として、zsh を経由せず起動される GUI アプリや launchd ジョブからは mise のツールが
見えない。現状の用途（Ghostty → zsh → neovim）では問題にならない。

## 移行対象

### mise へ移す

レジストリ収載（`aqua:` / `core:` バックエンド）:

```
StyLua actionlint aqua bat biome buf delta dprint fd fzf gh gitleaks
golangci-lint hyperfine just lazygit protolint ripgrep starship taplo
television tree-sitter uv vale worktrunk xh
go node bun terraform terraform-ls lua-language-server yamlfmt hadolint
cue atlas oxlint tealdeer pre-commit 1password-cli
```

レジストリ外（バックエンドを明示）:

```
github:  Feel-ix-343/markdown-oxide  docker/docker-language-server
         reteps/dockerfmt  quarylabs/sqruff
npm:     typescript-language-server  yaml-language-server
         @tailwindcss/language-server
```

`ubi:` バックエンドは非推奨（mise 2027.1.0 で削除予定）なので `github:` を使う。

### `/nix` に残す

```
mise         Home Manager がビルド時に `mise completion bash` を実行するため実体が必要
nixd nixfmt nixfmt-tree cachix home-manager   Nix ツールチェーン
gopls        go: バックエンドはソースビルドになる
eza          cargo: バックエンドのみ
sqlfluff     pipx: バックエンドのみ
google-cloud-sdk skim luarocks clang-tools wget gotools lua
llm-agents.codex / opencode / claude-code     overlay 由来
pkgs.gh-poi  programs.gh.extensions 経由
```

### 削除する

- `packages/`（29 ファイル）
- ルートの `config.toml`
- `flake.nix` の `localPackages` 定義と `extraSpecialArgs` への受け渡し
- `CLAUDE.md` の bin2nix に関する記述

`packages/codex.nix` と `packages/oxc.nix` は現時点で参照されていない（codex は overlay、
oxlint は `pkgs.oxlint` から来ている）ため、そのまま消えるだけである。

## 検証済みの事実

この設計を書く前に実機で確認した。

- mise のレジストリは bin2nix の 27 ツールすべてを収載しており、いずれも `aqua:` バックエンド
- `buildEnv` は store 外への dangling symlink を警告のみで受け入れ、ビルドは成功する
  （`mise install` 後にリンクは解決される）
- shim 経由の起動コストは 13.4ms、実パス直叩きは 4.7ms（`starship --version`、50 回、hyperfine）
- `starship init zsh` は `current_exe()` で解決した**実パス**を `PROMPT` に焼き込む。
  したがって shim を挟んでもプロンプト再描画のたびにコストを払うことはなく、
  シェル起動時の `init` 1 回だけである
- レジストリ外の 7 つ（`github:` 4 つ、`npm:` 3 つ）は実際にインストールして成功を確認した。
  生成される shim 名は `markdown-oxide` `docker-language-server` `dockerfmt` `sqruff`
  `typescript-language-server` `yaml-language-server` `tailwindcss-language-server` で、
  neovim の conform / nvim-lint / `vim.lsp.enable` が名前で参照している実行ファイル名と一致する
- mise のインストール先レイアウトはツールごとに異なる
  （`starship/1.26.0/starship`、`gh/2.98.0/gh_2.98.0_macOS_arm64/bin/gh`、
  `fd/10.4.2/fd-v10.4.2-aarch64-apple-darwin/fd`）。
  実パスを Nix 側で組み立てることはできないため、`mkMiseBin` は shims を経由する

## トレードオフ

**失うもの**

- ハッシュの記録。`mise.lock` は設定ファイルの隣に書かれるため、`config.toml` が
  `/nix/store` 上にある構成では使えない。固定できるのはバージョンまでで、
  「同じバージョンが同じ成果物であること」をローカルに記録した台帳は持てない。
  ただし検証がなくなるわけではない。実測では `github:` バックエンドが
  ダウンロードのたびに checksum・GitHub artifact attestation・SLSA provenance を
  検証しており、`aqua:` バックエンドも checksum を検証する。
  bin2nix の固定ハッシュより、供給元の署名に寄せた検証に変わる
- `home-manager build` によるツール一覧の検証。何が入るかはビルド時にはわからず、
  activation 時にはじめて確定する
- ロールバックの粒度。Nix 世代を戻してもすでにインストール済みの mise ツールは戻らない

**得るもの**

- 実行ファイルが Falcon の除外パス配下に載る
- `bin2nix` という自作ツールへの依存がなくなる
- バージョン更新が `mise outdated` で一覧できる

## 移行手順

1. `home-manager/mise.nix` を新設（`miseTools`、`mkMiseBin`、`programs.mise`、activation）
2. `home-manager/gh.nix` と `home-manager/starship.nix` の `package` を差し替え
3. `home-manager/base.nix` の `home.packages` から移行対象を削除
4. `flake.nix` から `localPackages` を削除
5. `packages/` と `config.toml` を削除
6. `home-manager build --flake .#earlgray` で差分確認 → `just switch-home-manager`
7. 全ツールの `which` とバージョンを確認
8. `CLAUDE.md` の bin2nix 記述を mise 運用に書き換え

各ツールの固定バージョンは `mise latest <tool>` で取得して埋める。

## ロールバック

`git revert` して `home-manager switch` すれば `/nix` 側の構成に戻る。
`~/.local/share/mise/installs/` は残るが、PATH から外れるだけで無害。
不要なら `mise prune` で削除する。
