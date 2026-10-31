# nix-dotfiles

macOS environment managed by nix-darwin, Home Manager and mise.

## 管理方針

- **nix-darwin**: macOS のシステム設定、Homebrew、ホスト全体に必要なものを管理する。
- **Home Manager**: ユーザー環境と、Claude Code・Codex・OpenCodeの静的設定、プラグイン、skills、hooksを宣言的に管理する。
- **lib**: Home Managerが利用する変換関数とartifact生成処理を管理する。
- **mise**: 開発用 CLI とランタイムを `mise/mise.toml` と `mise/mise.lock` で管理する。OpenCode と `cloudflared` もここに含む。Nix が必要な `nixd` と `nixfmt` は例外として Nix のままにする。gcloud は macOS 版に Python が同梱されないため、mise の `python` を `CLOUDSDK_PYTHON` で参照する。

何が Nix 管理で何が管理外かは [ARCHITECTURE.md の「Nix管理の境界」](ARCHITECTURE.md#nix管理の境界) にまとめている。

macOS 上のアプリと CLI の導入経路は、公式 installer（Claude Code、Codex）、Homebrew（nix-darwin の `homebrew.casks` / `brews`）、mise、Nix の4つに限る。それ以外で入れたものは、これらのいずれかへ移す。バイナリは原則 mise・公式 installer・Homebrew で入れ、Nix は設定ファイルの生成に使う。mise 本体は公式 installer（`just install-mise-cli`、`~/.local/bin/mise`）、AeroSpace は Homebrew、git は Xcode Command Line Tools、zsh は macOS 標準の `/bin/zsh` を使う。Home Manager module が本体を要求する場合は `package = null` か、`mkMiseBin` で mise の shim を渡す（gh、starship、direnv）。neovim は plugin を Nix で組み込むため、現状は Nix のままにする。

編集場所の判断に迷ったら、システム全体なら`nix-darwin/`、宣言的なユーザー設定なら`home-manager/`、その変換・生成ロジックなら`lib/`、開発ツールのバージョンなら`mise/mise.toml`を編集する。

`~/.claude/settings.json`、`~/.codex/config.toml`、`~/.config/opencode/opencode.json`はHome Managerが生成し、編集可能な実ファイルとして配置する。恒久的な変更は対応するNix moduleへ記述する。switch時にNix外での変更（drift）を検知するとdiffを表示して中止するので、Nixへ取り込むか`HM_EDITABLE_FORCE=1 just switch-home-manager`で上書きする。

Claude CodeとCodexのCLI本体は公式installerが`~/.local/bin`配下へ配置し、各CLIのnative updaterで更新する。認証、履歴、session、DB、cacheなどのruntime stateは各アプリ自身が管理し、Nixには取り込まない。

### miseツールの変更

開発ツールの追加・削除は`mise/mise.toml`を編集し、`just install-mise`でlock済みversionを導入する。全toolのpin更新は`just update-mise`でconfigとlockfileを更新する。Home Manager switchはmise本体と設定symlinkだけを反映し、toolのdownloadは行わない。Goはmiseによる`GOBIN`設定を無効にし、versionに依存しない`~/go/bin`をPATHへ加える。

## MCP

MCPサーバーの唯一の正本は`home-manager/ai/mcp.nix`の`programs.mcp.servers`。Home ManagerのMCP統合がClaude Code、Codex、OpenCodeの最終設定へ直接配布する。

## AI extensions

Claude Code と Codex の拡張は `home-manager/ai/extensions.nix` で選択する。Ponytailのように両クライアントのnative manifestを持つpluginは、同じpin済みflake inputから双方へ配布する。Claude Code専用pluginはCodexへ変換せず、Codexにはnative pluginまたはAgent Skills仕様のskillだけを配布する。

Anthropic公式skillsはClaude Codeだけへ配布する。Google Cloud skillsはCloud Run、Firebase、Spannerと主要なGKE運用skillに限定する。CodexのOpenAI公式拡張は旧`openai/skills`ではなく`openai/plugins`のnative pluginを利用する。GitHub pluginは共有GitHub MCPと重複するため導入せず、既存のGitHub MCPと`github/awesome-copilot` skillsを使う。

ローカルで作成・改善するSkillは`home-manager/ai/skills/<name>/SKILL.md`を正本とし、外部Skillと同名の場合はローカル版を優先する。生成先の`~/.claude/skills`や`~/.codex/skills`は直接編集しない。

## AI設定の変更

| やりたいこと | 編集場所 | 検証・反映 |
|---|---|---|
| Claude Codeのmodel・permissions・hooks変更 | `home-manager/ai/claude.nix` | `just test-ai` → `just switch-home-manager` |
| Codexのmodel・approval・trust・hooks変更 | `home-manager/ai/codex.nix` | `just test-ai` → `just switch-home-manager` |
| MCP追加 | `home-manager/ai/mcp.nix` | `just test-ai` → `just switch-home-manager` |
| 外部plugin・Skill追加 | `flake.nix`、`home-manager/ai/extensions.nix` | `just test-ai` → `just switch-home-manager` |
| ローカルSkill作成・改善 | `home-manager/ai/skills/<name>/SKILL.md` | `just test-ai` → `just switch-home-manager` |
| 両CLIの初回導入・復旧 | 変更不要 | `just install-ai` |
| 導入済み両CLIの更新 | 変更不要 | `just update-ai` |

## Install

**1. Nix** — <https://github.com/NixOS/nix-installer>

**2. nix-darwin**
```sh
sudo nix run nix-darwin -- switch --flake .#makabeee-macbook-pro
```

**3. Claude Code・Codexの公式CLI（初回・Nix管理からの移行時）**
```sh
nix run .#claude-code-installer -- latest
nix run .#codex-installer
```

**4. home-manager**
```sh
nix run home-manager/master -- switch --flake .#earlgray
```

## Apply changes

**全部まとめて更新して反映する: `just upgrade`**（flake input・AI CLI・miseツールを更新し、home-managerへ反映する。nix-darwinは含まない）

```sh
just switch-darwin-rebuild    # nix-darwin (requires sudo)
just switch-home-manager      # home-manager
just switch-all               # nix-darwin, then home-manager
just install-mise             # install locked development tools
just update-mise              # update mise pins and lock metadata
just update-ai                # update installed Claude Code and Codex CLIs
just update-nix               # bump flake inputs
just update-all               # bump flake inputs and update Claude Code / Codex (no switch)
just update                   # update flake inputs, AI CLIs and mise tools (no switch)
just upgrade                  # update, then switch-home-manager
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

初回・Nix管理からの移行時は上記の公式installerを先に実行し、その後`just switch-home-manager`で静的設定を反映する。以後の静的設定変更はswitchだけでよい。mise toolの導入・更新はswitchから分離されている。
Claude CodeとCodexのCLI内で設定を書き換える運用は行わない。書き込みに失敗するか、書き込めても次回switchでNix宣言へ戻る。恒久的な変更は`home-manager/ai/`配下の正本へ記述する。

Codex のGit・GitHubワークフローSkillは、GitHub公式の `github/awesome-copilot` をflake inputとして固定し、Home Managerから配布する。Skillの候補調査には `gh skill search` と `gh skill preview` を使うが、実体のインストール先はNix管理下とする。

Claude CodeとCodexは、初回導入・復旧では公式installer、通常更新ではnative updaterを明示的に実行する。`just switch-home-manager`からはいずれも実行しない。

```sh
just install-claude-code
just install-codex
just install-ai
just update-claude-code
just update-codex
just update-ai
```
