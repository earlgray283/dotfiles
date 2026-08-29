# dotfiles アーキテクチャ

このリポジトリは、システム設定・宣言的なユーザー環境・開発ツール・アプリケーションの最終設定を、それぞれ適した管理者に分けるハイブリッド構成である。

## 判断基準と編集場所

| 対象 | 管理者 | 正本・編集場所 | 判断基準 |
|---|---|---|---|
| macOS の defaults、Homebrew、ホスト設定 | nix-darwin | `nix-darwin/configuration.nix` | ユーザーをまたぐシステム状態、または macOS 固有の設定 |
| ユーザーパッケージ、シェル、エディタ、AI クライアントのパッケージ・プラグイン・skills・hooks | Home Manager | `home-manager/` | 宣言的に再現したいユーザー環境 |
| AI クライアントの共有 MCP サーバー | Home Manager | `home-manager/mcp.nix` の `programs.mcp.servers` | MCP 定義の唯一の正本 |
| 開発用 CLI とランタイム | mise | `home-manager/mise.nix` の `miseTools` | バージョンを mise で解決し、バイナリを `$HOME` 配下で管理するもの |
| Nix 固有のツール | Home Manager / Nix | `home-manager/base.nix` | `nixd`、`nixfmt`、`nixfmt-tree` のように Nix 環境が必要な例外 |
| Claude Code の最終設定 | chezmoi | `chezmoi/dot_claude/settings.json` | Claude Code 自身が書き換える設定 |
| Codex の最終設定 | chezmoi modify | `chezmoi/dot_codex/modify_config.toml` | 現在の可変設定を保持し、MCP 部分だけを HM 生成 template で置換 |

Claude Code の `CLAUDE.md`、hooks、パッケージ、plugins、marketplaces、skills と、Codex の `AGENTS.md`、hooks、パッケージ、skills は Home Manager 所有である。Claude専用pluginをCodexへwrapperとして配布せず、CodexにはAgent Skills仕様に対応したSkillだけを配布する。最終設定との境界を越えて同じファイルを二重管理しない。

## MCP の配布

`home-manager/mcp.nix` の `programs.mcp.servers` が MCP の唯一の正本である。Home Manager は同じ定義を次の 3 クライアントへ配布する。

1. Claude Code: Home Manager の Claude Code MCP 統合。
2. OpenCode: Home Manager の OpenCode MCP 統合。
3. Codex: `home-manager/chezmoi.nix` が `lib.hm.mcp` で TOML fragment を生成し、`modify_config.toml` が現在の TOML を読み込んで `mcp_servers` だけを置換する。対象が無いか空の場合は `codex-baseline.toml` から初期設定を生成する。

生成された `chezmoi/.chezmoitemplates/nix/codex-mcp-servers.toml` は Home Manager の出力なので直接編集しない。サーバーを追加・変更するときは `home-manager/mcp.nix` だけを編集して、Home Manager を再適用する。

## 適用フロー

```text
nix-darwin の変更       -> just switch-darwin-rebuild (必要時)
Home Manager / mise の変更 -> just apply-dotfiles
                               ├─ just switch-home-manager
                               └─ chezmoi apply
```

`just apply-dotfiles` は Home Manager の switch を先に実行し、その後 chezmoi を apply する。これにより、chezmoi の Codex template が参照する Home Manager 管理の MCP fragment も先に更新される。個別に確認する場合は、`just switch-home-manager` と `chezmoi apply` を分けて実行できる。

Claude Code の操作で最終設定が書き換わった場合は、次の順序で正本へ戻す。

```sh
chezmoi diff                         # 現在の実体と chezmoi 正本の差分を確認
chezmoi re-add ~/.claude/settings.json  # Claude Code の変更を採用する場合
git diff
```

Codex の hook trust などの可変設定は `just apply-dotfiles` により現在の `~/.codex/config.toml` から自動的に保持され、MCP 部分だけが置換される。Codex 用の `chezmoi re-add` は不要である。採用しない Claude Code の差分は `re-add` せず、正本を編集した場合も `chezmoi diff` で適用結果を確認する。
