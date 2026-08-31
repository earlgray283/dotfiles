# dotfiles アーキテクチャ

このリポジトリは、再現性を優先する設定をNix、ホームディレクトリ配下へ置く開発ツールをmise、miseの可変設定をchezmoiで管理する。

## 判断基準と編集場所

| 対象 | 管理者 | 正本・編集場所 |
|---|---|---|
| macOS defaults、Homebrew、ホスト設定 | nix-darwin | `nix-darwin/configuration.nix` |
| ユーザーパッケージ、シェル、エディタ | Home Manager | `home-manager/` |
| Claude Codeの最終設定・plugins・skills・hooks | Home Manager | `home-manager/claude-code/claude-code.nix`、`home-manager/ai-extensions.nix` |
| Codexの最終設定・plugins・skills・hooks | Home Manager | `home-manager/codex.nix`、`home-manager/ai-extensions.nix` |
| OpenCodeの設定 | Home Manager | `home-manager/opencode.nix` |
| 共有MCPサーバー | Home Manager | `home-manager/mcp.nix` |
| 開発用CLIとランタイム | mise | `home-manager/mise.nix`の`miseTools` |
| miseの最終設定 | chezmoi modify | `chezmoi/dot_config/mise/modify_config.toml` |
| Nix固有のツール | Home Manager / Nix | `home-manager/base.nix` |

Claude CodeとCodexの最終設定はNix storeへのsymlinkになる。chezmoiのsource stateやmodify templateは介在しない。CLI内で設定を書き換えられない、または書き換えても次回switchで失われる制約を受け入れ、単一の宣言的な正本を優先する。

## MCPの配布

`home-manager/mcp.nix`の`programs.mcp.servers`が唯一の正本である。Home Managerの各moduleがクライアント固有形式へ変換する。

```text
home-manager/mcp.nix
        ↓ just switch-home-manager
Home Manager
├─ Claude Code MCP plugin
├─ Codex ~/.codex/config.toml
└─ OpenCode ~/.config/opencode/opencode.json
```

Codexでは`headers`が`http_headers`へ変換され、stdio MCPのenv fileは必要に応じてwrapperへ変換される。変換はHome Manager moduleの`enableMcpIntegration`へ任せ、独自fragmentは生成しない。

npmで配布されるstdio MCPを追加するときはmise配下の`bunx`を優先し、パッケージのバージョンを固定する。HTTP MCPと単独バイナリのMCPは対象外である。

## Claude Code・Codexの設定変更

マージ処理は行わない。現在の最終設定を入力として読むことも、CLIによる差分をNixへ逆流させることもない。恒久的な変更はNixの正本へ記述する。

| 変更対象 | 編集場所 |
|---|---|
| Claude Code settings・permissions・hooks | `home-manager/claude-code/claude-code.nix` |
| Codex model・approval・project trust・hook trust | `home-manager/codex.nix` |
| 両クライアントのplugins・skills | `home-manager/ai-extensions.nix` |
| MCPサーバー | `home-manager/mcp.nix` |

Codex pluginのhook hashが更新された場合も、CLIに記録させるのではなく`home-manager/codex.nix`の`hooks.state`を更新する。

```text
Nix moduleを編集
        ↓ just switch-home-manager
Home Managerが新しい最終設定を生成
        ↓
~/.claude/settings.json / ~/.codex/config.toml のsymlinkを更新
```

CLIが設定変更を要求した場合は、その変更内容を対応するNix moduleへ移してswitchする。Git conflictの解消や3-way mergeは発生しない。

## pluginsとskills

Claude専用pluginをCodex向けwrapperへ変換しない。PonytailのようにCodex native manifestを持つpluginと、Agent Skills仕様のskillだけをCodexへ配布する。

```text
pin済みsource
├─ Claude Code: ~/.claude/skills
└─ Codex
   ├─ ~/.codex/skills
   ├─ ~/.agents/plugins/marketplace.json
   └─ ~/.codex/plugins/cache/home-manager
```

拡張の選択と配布先は`home-manager/ai-extensions.nix`を正本とする。

- Anthropic公式skillsはClaude Codeだけへ配布する。既存のClaude公式pluginと名前が衝突するskillは重複配布しない。
- Google Cloud skillsはCloud Run、Firebase、Spannerと主要なGKE運用skillだけをClaude CodeとCodexへ配布する。
- OpenAI公式拡張は`openai/plugins`からCodex native pluginとして配布する。現在はFigma、Linear、Notion、Codex Security、OpenAI Developersを選択している。
- GitHubは`home-manager/mcp.nix`の共有MCPと`github/awesome-copilot` skillsを使用する。独自MCPを同梱するOpenAI GitHub pluginは重複を避けるため配布しない。

## miseとchezmoi

miseだけはハイブリッド管理を維持する。Home Managerが`miseTools` fragmentを生成し、chezmoi modifyが現在の`~/.config/mise/config.toml`へ合成する。Nix宣言のtool versionが優先され、それ以外のmise設定は保持される。このmerge処理はClaude CodeとCodexには適用しない。

## 適用フロー

```text
nix-darwinの変更          -> just switch-darwin-rebuild
Home Manager / miseの変更 -> just switch-home-manager
                              ├─ Claude Code・Codexを直接配置
                              └─ chezmoi applyでmiseを合成
```

通常は`just switch-home-manager`だけでよい。`just apply-dotfiles`は互換用aliasである。
