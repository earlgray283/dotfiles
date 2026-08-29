# nix-dotfiles

macOS environment managed by nix-darwin, Home Manager, mise and chezmoi.

## 管理方針

- **nix-darwin**: macOS のシステム設定、Homebrew、ホスト全体に必要なものを管理する。
- **Home Manager**: ユーザー環境のパッケージ、各 AI クライアントのパッケージ・プラグイン・スキル・フック、共有設定を管理する。
- **mise**: 開発用 CLI とランタイムのバージョンを `home-manager/mise.nix` の `miseTools` で管理する。Nix が必要な `nixd`、`nixfmt`、`nixfmt-tree` は例外として Nix のままにする。
- **chezmoi**: ツール自身が書き換える Claude Code の最終設定 (`~/.claude/settings.json`) と Codex の最終設定 (`~/.codex/config.toml`) を管理する。正本は `chezmoi/` に置き、同じファイルを Home Manager で重複管理しない。

編集場所の判断に迷ったら、システム全体なら `nix-darwin/`、宣言的なユーザー環境なら `home-manager/`、開発ツールのバージョンなら `home-manager/mise.nix`、アプリが実行時に更新する最終設定なら `chezmoi/` を編集する。

## MCP

MCP サーバーの唯一の正本は `home-manager/mcp.nix` の `programs.mcp.servers`。ここから Claude Code と OpenCode へ Home Manager の MCP 統合で配布し、Codex へは `home-manager/chezmoi.nix` が生成する `.chezmoitemplates/nix/codex-mcp-servers.toml` を `chezmoi/dot_codex/modify_config.toml` が取り込んで配布する。生成 fragment は編集しない。

## Install

**1. Nix** — <https://github.com/NixOS/nix-installer>

**2. nix-darwin**
```sh
sudo nix run nix-darwin -- switch --flake .#makabeee-macbook-pro
```

**3. home-manager**
```sh
nix run home-manager/master -- switch --flake .#earlgray
```

## Apply changes

```sh
just switch-darwin-rebuild    # nix-darwin (requires sudo)
just switch-home-manager      # home-manager
just apply-dotfiles            # home-manager switch followed by chezmoi apply
just fmt                      # format (treefmt)
just lint                     # lint (deadnix, report only)
just lint-fix                 # lint and rewrite the sources
just check                    # everything CI runs
```

CI invokes the same recipes via `nix run .#just`, so `just check` passing locally
means CI runs the identical commands.

Dry-run before applying:
```sh
darwin-rebuild build --flake .#makabeee-macbook-pro
home-manager build --flake .#earlgray
```

通常のユーザー環境の反映は `just apply-dotfiles`（Home Manager の switch 後に chezmoi apply）を使う。macOS システム設定を変更した場合は、必要に応じて先に `just switch-darwin-rebuild` を実行する。

Claude Code が最終設定を書き換えた場合は、まず `chezmoi diff` で差分を確認し、採用する変更だけを `chezmoi re-add ~/.claude/settings.json` で `chezmoi/` の正本へ戻す。その後 `git diff` を確認してから `just apply-dotfiles` を実行する。Codex の可変設定（hook trust と plugin 状態を含む）は現在の `~/.codex/config.toml` から保持され、`just apply-dotfiles` は Home Manager が生成した MCP 部分だけを更新するため、Codex 用の `re-add` は不要である。

Codex のGit・GitHubワークフローSkillは、GitHub公式の `github/awesome-copilot` をflake inputとして固定し、Home Managerから配布する。Skillの候補調査には `gh skill search` と `gh skill preview` を使うが、実体のインストール先はNix管理下とする。

## Package management (`packages/`)

Managed by `bin2nix` — do not edit manually. Add packages to `config.toml`, then run:
```sh
bin2nix update          # refresh all packages
bin2nix add <owner/repo>
```
