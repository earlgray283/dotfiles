# nix-dotfiles

macOS environment managed by nix-darwin, Home Manager, mise and chezmoi.

## 管理方針

- **nix-darwin**: macOS のシステム設定、Homebrew、ホスト全体に必要なものを管理する。
- **Home Manager**: ユーザー環境のパッケージ、各 AI クライアントのパッケージ・プラグイン・スキル・フック、共有設定を管理する。
- **mise**: 開発用 CLI とランタイムのバージョンを `home-manager/mise.nix` の `miseTools` で管理する。Nix が必要な `nixd`、`nixfmt`、`nixfmt-tree` は例外として Nix のままにする。
- **chezmoi**: Claude Code、Codex、mise の可変な最終設定を modify template で管理する。Home Manager が生成した fragment と現在値を合成し、同じファイルを Home Manager で重複管理しない。

編集場所の判断に迷ったら、システム全体なら `nix-darwin/`、宣言的なユーザー環境なら `home-manager/`、開発ツールのバージョンなら `home-manager/mise.nix`、アプリが実行時に更新する最終設定なら `chezmoi/` を編集する。

## MCP

MCP サーバーの唯一の正本は `home-manager/mcp.nix` の `programs.mcp.servers`。ここから Claude Code と OpenCode へ Home Manager の MCP 統合で配布し、Codex へは `home-manager/chezmoi.nix` が生成する `.chezmoitemplates/nix/codex-mcp-servers.toml` を `chezmoi/dot_codex/modify_config.toml` が取り込んで配布する。生成 fragment は編集しない。

## AI extensions

Claude Code と Codex の拡張は `home-manager/ai-extensions.nix` で選択する。Ponytailのように両クライアントのnative manifestを持つpluginは、同じpin済みflake inputから双方へ配布する。Claude Code専用pluginはCodexへ変換せず、Codexにはnative pluginまたはAgent Skills仕様のskillだけを配布する。

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
just apply-dotfiles            # compatibility alias for switch-home-manager
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

通常のユーザー環境は `just switch-home-manager` で反映する。Home Manager activation が fragment の生成後に `chezmoi apply` まで実行する。`just apply-dotfiles` は互換用の alias として残す。macOS システム設定を変更した場合は、必要に応じて先に `just switch-darwin-rebuild` を実行する。

Claude Code、Codex、mise の可変設定は現在の最終設定から保持される。Home Manager の再適用では、Claude Code の宣言的設定、Codex の MCP、mise の tools だけを Nix 生成 fragment から更新するため、`re-add` は不要である。

Codex のGit・GitHubワークフローSkillは、GitHub公式の `github/awesome-copilot` をflake inputとして固定し、Home Managerから配布する。Skillの候補調査には `gh skill search` と `gh skill preview` を使うが、実体のインストール先はNix管理下とする。

## Package management (`packages/`)

Managed by `bin2nix` — do not edit manually. Add packages to `config.toml`, then run:
```sh
bin2nix update          # refresh all packages
bin2nix add <owner/repo>
```
