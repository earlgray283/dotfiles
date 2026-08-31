# nix-dotfiles

macOS environment managed by nix-darwin, Home Manager, mise and chezmoi.

## 管理方針

- **nix-darwin**: macOS のシステム設定、Homebrew、ホスト全体に必要なものを管理する。
- **Home Manager**: ユーザー環境と、Claude Code・Codex・OpenCodeの最終設定、パッケージ、プラグイン、skills、hooksを宣言的に管理する。
- **lib**: Home Managerが利用する変換関数とartifact生成処理を管理する。
- **mise**: 開発用 CLI とランタイムのバージョンを `home-manager/mise.nix` の `miseTools` で管理する。Nix が必要な `nixd`、`nixfmt`、`nixfmt-tree` は例外として Nix のままにする。
- **chezmoi**: miseの可変な最終設定をmodify templateで管理する。Home Managerが生成したtools fragmentと現在値を合成する。

編集場所の判断に迷ったら、システム全体なら`nix-darwin/`、宣言的なユーザー設定なら`home-manager/`、その変換・生成ロジックなら`lib/`、開発ツールのバージョンなら`home-manager/mise.nix`、miseの可変設定なら`chezmoi/`を編集する。

Claude CodeとCodexにはchezmoiによるmerge処理を設けない。`~/.claude/settings.json`と`~/.codex/config.toml`はHome Managerが生成するNix storeへのsymlinkであり、恒久的な変更は対応するNix moduleへ記述する。

### miseツールの変更

開発ツールの追加・更新・削除は`home-manager/mise.nix`の`miseTools`を編集し、`just switch-home-manager`で反映する。activationが`mise install`と`mise reshim`を実行するため、手動の`mise install`や`mise up`は不要。

## MCP

MCPサーバーの唯一の正本は`home-manager/mcp.nix`の`programs.mcp.servers`。Home ManagerのMCP統合がClaude Code、Codex、OpenCodeの最終設定へ直接配布する。

## AI extensions

Claude Code と Codex の拡張は `home-manager/ai-extensions.nix` で選択する。Ponytailのように両クライアントのnative manifestを持つpluginは、同じpin済みflake inputから双方へ配布する。Claude Code専用pluginはCodexへ変換せず、Codexにはnative pluginまたはAgent Skills仕様のskillだけを配布する。

Anthropic公式skillsはClaude Codeだけへ配布する。Google Cloud skillsはCloud Run、Firebase、Spannerと主要なGKE運用skillに限定する。CodexのOpenAI公式拡張は旧`openai/skills`ではなく`openai/plugins`のnative pluginを利用する。GitHub pluginは共有GitHub MCPと重複するため導入せず、既存のGitHub MCPと`github/awesome-copilot` skillsを使う。

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

通常のユーザー環境は`just switch-home-manager`で反映する。Home ManagerがClaude Code・Codexの最終設定を生成して直接配置し、activation内の`chezmoi apply`がmise設定だけを合成する。`just apply-dotfiles`は互換用のaliasとして残す。

Claude CodeとCodexのCLI内で設定を書き換える運用は行わない。書き込みに失敗するか、書き込めても次回switchでNix宣言へ戻る。恒久的な変更は`home-manager/claude-code/claude-code.nix`または`home-manager/codex.nix`へ記述する。miseの可変設定だけは引き続き保持される。

Codex のGit・GitHubワークフローSkillは、GitHub公式の `github/awesome-copilot` をflake inputとして固定し、Home Managerから配布する。Skillの候補調査には `gh skill search` と `gh skill preview` を使うが、実体のインストール先はNix管理下とする。

## Package management (`packages/`)

CodexとOpenCodeは`bin2nix`で公式GitHub Releaseから生成する。`packages/`は直接編集せず、`config.toml`を変更してから実行する。

```sh
bin2nix update          # refresh all packages
bin2nix add <owner/repo>
```

Claude CodeはGitHub Releaseを提供していないため、`llm-agents.nix`がAnthropic公式バイナリを取得する例外とする。Numtideのbinary cacheは使用しない。
