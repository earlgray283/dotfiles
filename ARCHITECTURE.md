# dotfiles アーキテクチャ

このリポジトリは、システム設定・宣言的なユーザー環境・開発ツール・アプリケーションの最終設定を、それぞれ適した管理者に分けるハイブリッド構成である。

## 判断基準と編集場所

| 対象 | 管理者 | 正本・編集場所 | 判断基準 |
|---|---|---|---|
| macOS の defaults、Homebrew、ホスト設定 | nix-darwin | `nix-darwin/configuration.nix` | ユーザーをまたぐシステム状態、または macOS 固有の設定 |
| ユーザーパッケージ、シェル、エディタ、AI クライアントのパッケージ・プラグイン・skills・hooks | Home Manager | `home-manager/` | 宣言的に再現したいユーザー環境 |
| AI クライアントの共有 MCP サーバー | Home Manager | `home-manager/mcp.nix` の `programs.mcp.servers` | MCP 定義の唯一の正本 |
| 開発用 CLI とランタイム | Nix fragment + chezmoi modify | `home-manager/mise.nix` の `miseTools`、`chezmoi/dot_config/mise/modify_config.toml` | Nix 宣言ツールを現在の mise 設定へ合成し、バイナリを `$HOME` 配下へ置くもの |
| Nix 固有のツール | Home Manager / Nix | `home-manager/base.nix` | `nixd`、`nixfmt`、`nixfmt-tree` のように Nix 環境が必要な例外 |
| Claude Code の最終設定 | chezmoi modify | `chezmoi/dot_claude/modify_settings.json` | 現在値を保持し、HM 生成の宣言的設定を合成 |
| Codex の最終設定 | chezmoi modify | `chezmoi/dot_codex/modify_config.toml` | 現在の可変設定を保持し、MCPとNix管理pluginをHM生成templateから反映 |
| mise の最終設定 | chezmoi modify | `chezmoi/dot_config/mise/modify_config.toml` | 現在の追加設定を保持し、HM 生成の tools fragment を合成 |

Claude Code の `CLAUDE.md`、hooks、パッケージ、plugins、marketplaces、skills と、Codex の `AGENTS.md`、hooks、パッケージ、native plugins、skills は Home Manager 所有である。Claude専用pluginをCodexへwrapperとして配布せず、PonytailのようにCodex native manifestを持つpluginと、Agent Skills仕様に対応したskillだけを配布する。最終設定との境界を越えて同じファイルを二重管理しない。

## MCP の配布

`home-manager/mcp.nix` の `programs.mcp.servers` が MCP の唯一の正本である。Home Manager は同じ定義を次の 3 クライアントへ配布する。

1. Claude Code: Home Manager の Claude Code MCP 統合。
2. OpenCode: Home Manager の OpenCode MCP 統合。
3. Codex: `home-manager/chezmoi.nix` が `lib.hm.mcp` で TOML fragment を生成し、`modify_config.toml` が現在の TOML を読み込んで `mcp_servers` だけを置換する。対象が無いか空の場合は `codex-baseline.toml` から初期設定を生成する。

Claude Code は Home Manager 生成の JSON fragment を現在値へ再帰的に合成し、permission 配列を和集合にする。mise は `miseTools` の TOML fragment を現在の `tools` と合成し、Nix 宣言のバージョンを優先する。どちらも未知の設定を保持する。

生成された `chezmoi/.chezmoitemplates/nix/codex-mcp-servers.toml` は Home Manager の出力なので直接編集しない。サーバーを追加・変更するときは `home-manager/mcp.nix` だけを編集して、Home Manager を再適用する。

npmで配布されるstdio MCPを自分で定義する場合は、mise配下の`bunx`を優先し、パッケージのバージョンを固定する。外部plugin内の実行コマンドは一律変換せず、互換性を確認できたものだけ変更する。HTTP MCPと単独バイナリのMCPは対象外である。

### MCP を変更したときの反映経路

MCP サーバーを追加・変更・削除するときは、`home-manager/mcp.nix` の `programs.mcp.servers` だけを編集する。

```text
home-manager/mcp.nix
        ↓ just switch-home-manager
Home Manager
├─ Claude Code用の共有MCP設定を生成
│  └─ ~/.config/mcp/mcp.json
├─ OpenCode用設定を生成
└─ Codex用TOML fragmentを生成
   └─ chezmoi/.chezmoitemplates/nix/codex-mcp-servers.toml
            ↓ chezmoi apply
      ~/.codex/config.toml の mcp_servers を置換
```

Claude Code の MCP は Home Manager の MCP 統合から読み込まれるため、`~/.claude/settings.json` へ同じ定義を複製しない。Codex はクライアント固有の形式へ変換し、`headers` を `http_headers`、無効状態を `enabled`、stdio の引数と環境変数を Codex の TOML 形式へ変換する。

通常は次の1コマンドで、fragment生成から両クライアントへの反映まで完了する。

```sh
just switch-home-manager
```

## Claude Code・Codexが設定を書き換えた後のマージ

git の conflict 解消は行わない。chezmoi の modify template が、現在の最終設定を入力として読み、Nix が所有する部分だけを決められた規則で合成する。

### Claude Code

```text
現在の ~/.claude/settings.json
        +
Nix生成の claude-settings.json
        ↓ chezmoi modify
更新後の ~/.claude/settings.json
```

| 設定 | マージ規則 |
|---|---|
| `permissions.allow`、`deny`、`ask` | 現在値とNix値の和集合。Claude Codeが追加したpermissionを保持 |
| `env`などのオブジェクト | 再帰マージ。競合するキーはNix値を優先 |
| `hooks`、`sandbox`などNix宣言部分 | Nix値を反映 |
| `model`、`effortLevel`、未知のキー | 現在値を保持 |

たとえばClaude Codeがpermissionを追加した後にNix側でhookを変更しても、次回switchではpermissionを残したままhookだけが更新される。

### Codex

```text
現在の ~/.codex/config.toml
        +
Nix生成の codex-mcp-servers.toml
        ↓ chezmoi modify
更新後の ~/.codex/config.toml
```

Codexでは`mcp_servers`セクション全体をNix生成値で置換する。それ以外のmodel、approval設定、project trust、hook trustなどは現在値をそのまま保持する。したがって、Codexがhook trustを更新した後にMCPサーバーを変更してswitchしても、hook trustは失われない。

Codex native pluginは、Home Managerがplugin cacheとpersonal marketplaceを生成し、`codex-plugins.toml` fragmentが対応する`plugins.<name>@home-manager.enabled`を最終設定へmergeする。Nix管理外のplugin状態は削除しない。

```text
pin済みplugin source
├─ Claude Code
│  ├─ marketplace
│  └─ ~/.claude/skills/<plugin>
└─ Codex
   ├─ ~/.agents/plugins/marketplace.json
   ├─ ~/.codex/plugins/cache/home-manager/<plugin>/<version>
   └─ codex-plugins.toml
      └─ ~/.codex/config.toml へmerge
```

どちらも最終ファイルをHome Managerのsymlinkにしないため、アプリは通常どおり書き込める。modify templateが現在値を直接読むので、変更後の`chezmoi re-add`は不要である。

## 適用フロー

```text
nix-darwin の変更          -> just switch-darwin-rebuild (必要時)
Home Manager / mise の変更 -> just switch-home-manager
                              └─ Home Manager activation
                                 └─ chezmoi apply
```

Home Manager activation は fragment の link 後に `chezmoi apply` を実行する。これにより、通常は `just switch-home-manager` だけで最終設定まで更新される。`just apply-dotfiles` は互換用の alias である。

modify template の適用差分は次のコマンドで確認できる。

```sh
chezmoi diff
```

Claude Code の permission、Codex の hook trust、mise の未宣言ツールなどの可変設定は現在の最終設定から保持される。Nix 宣言と競合する値は Nix 側を優先する。いずれも `chezmoi re-add` は不要である。
