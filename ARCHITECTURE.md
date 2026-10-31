# dotfiles アーキテクチャ

このリポジトリは、設定ファイルをNixで生成し、バイナリはmise・公式installer・Homebrewで導入する。

## 判断基準と編集場所

| 対象 | 管理者 | 正本・編集場所 |
|---|---|---|
| macOS defaults、Homebrew、ホスト設定 | nix-darwin | `nix-darwin/configuration.nix` |
| ユーザーパッケージ、シェル、エディタ | Home Manager | `home-manager/` |
| Claude Codeの静的設定・plugins・skills・hooks | Home Manager | `home-manager/ai/claude.nix`、`home-manager/ai/extensions.nix` |
| Codexの最終設定・plugins・skills・hooks | Home Manager | `home-manager/ai/codex.nix`、`home-manager/ai/extensions.nix` |
| Claude Code・CodexのCLI本体 | 公式installer | `lib/official-ai-installers.nix`、`justfile` |
| Claude Code・Codexのruntime state | 各アプリ | dotfiles管理外 |
| OpenCodeのCLI本体 | mise | `mise/mise.toml`、`mise/mise.lock` |
| OpenCodeの設定 | Home Manager | `home-manager/opencode.nix` |
| 共有MCPサーバー | Home Manager | `home-manager/ai/mcp.nix` |
| Home Manager向けの変換・生成ロジック | Nix library | `lib/` |
| 開発用CLIとランタイム | mise | `mise/mise.toml`、`mise/mise.lock` |
| mise本体 | 公式installer | `justfile`（`install-mise-cli`、`update-mise`） |
| miseのglobal config・lock | Home Manager | `home-manager/mise.nix` |
| Nix固有のツール | Home Manager / Nix | `home-manager/base.nix` |

## Nix管理の境界

Nixが「何を入れるか」を宣言していても、導入・更新は別の仕組みが行うものがある。どこにも宣言のないものは、新しいMacでは手作業で用意する。

**宣言はNix、導入はNix以外**

| 対象 | 宣言 | 導入・更新 | 実体の場所 |
|---|---|---|---|
| Homebrewのbrews・casks（AeroSpace、borders、openjdk、GUIアプリ） | `nix-darwin/configuration.nix` | `just switch-darwin-rebuild` | `/opt/homebrew`、`/Applications` |
| miseのtool | `mise/mise.toml`、`mise/mise.lock` | `just install-mise`、`just update-mise` | `~/.local/share/mise` |
| Claude Code・Codex本体 | `lib/official-ai-installers.nix` | `just install-ai`、`just update-ai` | `~/.local/bin` |

**Nixが生成し、実ファイルは編集可能**

| 対象 | 正本 | 備考 |
|---|---|---|
| `~/.claude/settings.json`、`~/.codex/config.toml`、`~/.config/opencode/opencode.json` | `home-manager/ai/claude.nix`、`home-manager/ai/codex.nix`、`home-manager/opencode.nix` | switch時にdriftを検知して中止 |

**宣言なし（dotfiles管理外）**

| 対象 | 用意する方法・所有者 |
|---|---|
| Nix本体・daemon・`/etc/nix/nix.conf` | [NixOS/nix-installer](https://github.com/NixOS/nix-installer)（`nix.enable = false`でnix-darwinに管理させない） |
| Homebrew本体 | 公式installerで手動導入 |
| Xcode Command Line Tools（初回のflake取得に使う`/usr/bin/git`。以後のgitはHome Managerの`pkgs.git`） | `xcode-select --install` |
| zsh本体とlogin shell | macOS標準の`/bin/zsh` |
| Claude Code・Codexの認証・履歴・session | 各アプリ |
| `~/.config/opencode`の`node_modules`、`package.json`、`opencode.jsonc` | OpenCode |
| `~/.zsh_history` | zsh |
| uvのPython（`~/.local/share/uv`） | uv |
| drift検知の記録（`~/.local/state/home-manager/editable-configs`） | `lib/editable-configs.nix`のactivation |
| アクセシビリティ等のmacOS権限（AeroSpace、Karabiner等） | システム設定で手動許可 |

Claude Code・Codex・OpenCodeの最終設定は、Nix storeへのsymlinkではなく編集可能な実ファイルとして配置する。CLI内からの設定変更を許しつつ、正本はNix moduleに置く。switch時に実ファイルが前回配置した内容とNixの生成内容のどちらとも異なればdriftとしてdiffを表示し、ファイルを書き換える前にswitchを中止する。`HM_EDITABLE_FORCE=1`を付けた場合だけ上書きする。

CLI本体は公式installerが`~/.local/bin`へ配置し、Nix storeには置かない。認証、履歴、session、DB、cacheなどのruntime stateは各アプリに書き込みを許可し、Nixには取り込まない。

`home-manager/`には設定値とHome Manager optionへの割当だけを置く。plugin・skillの変換、package・shim・assetの生成は`lib/`へ分離する。

## MCPの配布

`home-manager/ai/mcp.nix`の`programs.mcp.servers`が唯一の正本である。Home Managerの各moduleがクライアント固有形式へ変換する。

```text
home-manager/ai/mcp.nix
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
| Claude Code settings・permissions・hooks | `home-manager/ai/claude.nix` |
| Codex model・approval・project trust・hook trust | `home-manager/ai/codex.nix` |
| 両クライアントのplugins・skills | `home-manager/ai/extensions.nix` |
| MCPサーバー | `home-manager/ai/mcp.nix` |
| ローカルSkill | `home-manager/ai/skills/<name>/SKILL.md` |

Codex pluginのhook hashが更新された場合も、CLIに記録させるのではなく`home-manager/ai/codex.nix`の`hooks.state`を更新する。

```text
Nix moduleを編集
        ↓ just switch-home-manager
Home Managerが新しい最終設定を生成
        ↓
drift検知（実ファイルが外部で変更されていればdiffを表示して中止）
        ↓
~/.claude/settings.json / ~/.codex/config.toml / ~/.config/opencode/opencode.json へコピー
```

CLIで設定を変更した場合は、その変更内容を対応するNix moduleへ移してswitchする。Git conflictの解消や3-way mergeは行わない。

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

拡張の選択と配布先は`home-manager/ai/extensions.nix`を正本とする。ローカルSkillは`home-manager/ai/skills/`を正本とし、同名の外部Skillより優先する。

- Anthropic公式skillsはClaude Codeだけへ配布する。既存のClaude公式pluginと名前が衝突するskillは重複配布しない。
- Google Cloud skillsはCloud Run、Firebase、Spannerと主要なGKE運用skillだけをClaude CodeとCodexへ配布する。
- OpenAI公式拡張は`openai/plugins`からCodex native pluginとして配布する。現在はFigma、Linear、Notion、Codex Security、OpenAI Developersを選択している。
- GitHubは`home-manager/ai/mcp.nix`の共有MCPと`github/awesome-copilot` skillsを使用する。独自MCPを同梱するOpenAI GitHub pluginは重複を避けるため配布しない。

## mise

`mise/mise.toml`がtool selectorとmise設定、`mise/mise.lock`が解決済みURLとchecksumの正本である。mise本体は公式installerが`~/.local/bin`へ導入する。Home Managerはこれらをglobal configへlinkするだけで、activation中にtoolをinstallしない。`just install-mise`がlock済みtoolを導入し、`just update-mise`がpinとlock metadataを更新する。Goの`GOBIN`はmiseに設定させず、`~/go/bin`をstableなinstall先として使う。

## 適用フロー

```text
nix-darwinの変更       -> just switch-darwin-rebuild
Home Managerの変更    -> just switch-home-manager
mise toolの導入       -> just install-mise
mise toolのpin更新    -> just update-mise
AI CLIの初回導入・復旧 -> just install-ai
AI CLIの通常更新       -> just update-ai
```

初回・Nix管理からの移行時は両installerを実行してから`just switch-home-manager`する。以後の静的設定変更はswitchだけでよい。

## 新しいマシンへの導入

```text
1. xcode-select --install
2. curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install
3. sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .
4. just switch-home-manager
5. just install-mise-cli && just install-mise
6. just install-ai
```

Nixの導入にはNixOS/nix-installerを使う。DeterminateのinstallerはNixの構成が異なるため使わない。installerが`nix.conf`（`nix-command flakes`を有効化し`nix.custom.conf`を`!include`する）とdaemonを所有する。このリポジトリは`nix.custom.conf`の内容（`trusted-users`、`trusted-substituters`など）と、週次の`nix-gc`だけを`nix-darwin/configuration.nix`で宣言する。

nix-darwinがNixを管理していた環境から移行するときは、`/etc/nix/nix.conf`が消え、`*.before-nix-darwin`へ退避される。installer標準の`nix.conf`を`/etc/nix/nix.conf`へ置き直してから`just switch-home-manager`する。新しいマシンでは不要。
## AI CLIの供給元

OpenCodeはmiseが導入する。Home Manager moduleは`package = null`として、静的設定だけを生成する。

Claude CodeとCodexは`nix run`を明示したときに公式installerを取得・起動する。installerが配置したCLI本体とnative updaterは各vendorが所有する。Home Manager moduleは`package = null`として、静的設定だけを生成する。
