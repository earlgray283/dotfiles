# AGENTS.md / CLAUDE.md

この指示はあなたと User で共に育てていくものです。
User の指摘で恒久的な改善が必要だと判断した場合、この正本の更新を User に問うてください。

> **Claude CodeとCodexの静的設定はNix Home Manager、CLI本体は公式installer、runtime stateは各アプリ自身、開発toolはmiseで管理されています。正本以外を直接編集しないでください。**
>
> | 実体 | 所有者 | dotfiles での正本・編集場所 |
> |---|---|---|
> | `~/.claude/settings.json`（Claude Code 最終設定） | Home Manager | `home-manager/ai/claude.nix` |
> | `~/.codex/config.toml`（Codex 最終設定） | Home Manager | `home-manager/ai/codex.nix` |
> | Claude Code・CodexのCLI本体 | 公式installer | `lib/official-ai-installers.nix`、`justfile` |
> | Claude Code・Codexの認証・履歴・session・DB・cache | 各アプリ | dotfiles管理外 |
> | OpenCodeのpackage | bin2nix / Home Manager | `config.toml`、`packages/` |
> | `~/.config/mise/config.toml`、`mise.lock` | Home Manager / mise | `mise/mise.toml`、`mise/mise.lock`、`home-manager/mise.nix` |
> | Claude Code・Codexの共有指示 | Home Manager | `home-manager/ai/instructions.md` |
> | Claude Code hooks・plugins・skills | Home Manager | `home-manager/ai/claude.nix`、`home-manager/ai/hooks/`、`home-manager/ai/extensions.nix` |
> | Codex hooks・native plugins・skills | Home Manager | `home-manager/ai/codex.nix`、`home-manager/ai/extensions.nix` |
> | MCPサーバー | Home Manager | `home-manager/ai/mcp.nix` |
> | ローカルSkill | Home Manager | `home-manager/ai/skills/<name>/SKILL.md` |
> | `~/.config/opencode/` の構成 | Home Manager | `home-manager/opencode.nix` |

Claude CodeとCodexの最終ファイルを直接編集せず、変更は各Home Manager moduleへ記述して`just test-ai`で検証し、`just switch-home-manager`で反映します。CLI内からの変更は書き込みに失敗するか、次回switchで上書きされます。mise toolは`mise/mise.toml`と`mise/mise.lock`を編集し、`just install-mise`または`just update-mise`を明示的に実行します。Home Manager switchからtool installは行いません。

Claude CodeとCodexのCLI本体は`just install-ai`で初回導入・復旧し、`just update-ai`で通常更新します。`just switch-home-manager`からinstallerやupdaterを実行しません。runtime stateはNixへ取り込みません。

外部Skillはflake inputで固定し、`home-manager/ai/extensions.nix`で選択します。外部Skillを改善する場合は`home-manager/ai/skills/`へ同名で置き、ローカル版を優先させます。Nix storeや`~/.claude/skills`、`~/.codex/skills`を直接編集しません。

`home-manager/`には設定値とHome Manager optionへの割当だけを置きます。変換関数とpackage・shim・assetの生成処理は`lib/`へ置いてください。

npmで配布されるstdio MCPを`home-manager/ai/mcp.nix`へ追加するときは、mise配下の`bunx`を優先してパッケージのバージョンを固定します。外部plugin内の`npx`は一律変換せず、互換性を確認できたものだけ変更します。HTTP MCPと単独バイナリのMCPは対象外です。

# General Rules

- Response Language: **Always use Japanese (日本語)**.

# Behavior Rules

- 調査・確認作業は自分でツールを使って実行すること。どうしても自分で確認できない場合のみ User に依頼すること。

# Tools & Workflow

- Required CLI Tools:
    - **ALWAYS use `fd` instead of `find`. NEVER use `find`.**
    - **ALWAYS use `rg` instead of `grep`. NEVER use `grep`.**
- **Do NOT use the Task tool for file/code searches.** Use `fd` and `rg` directly via Bash tool.
- **GitHub contents access**: Use `gh` command (e.g. `gh api`, `gh repo view`) instead of `WebFetch` for GitHub URLs.

# Bash Rules

- **`cd` as a standalone command is ALLOWED** to change the working directory before subsequent commands.
- **Do NOT chain commands starting with `cd`** (e.g. `cd /path && git add ...` is forbidden — breaks permission matching in `settings.json`).
- **Do NOT use `git -C /path`** — use `cd /path` in a prior Bash call instead, for readability.
- Each Bash call must start with the actual command that matches a permission rule (i.e. the command after any `cd` in a chain would not match — hence no chains).
- **`sed` は使用不可** — `alias sed=gsed` があるが `gsed` は未インストール。`rg` / `awk` / Edit ツールを使うこと。
- **パイプの終了コードは `$pipestatus[1]`** — zsh なので `$?` はパイプ最終段の結果になる（`PIPESTATUS` は空）。`cmd | tail` で成否を判定しないこと。

# Coding Rules

- Code comments and identifiers should remain in English unless the project dictates otherwise.
- コード内コメントは最小限に。理由・計測値・トレードオフはコミットメッセージへ。コードに残すのは「無いと誤って修正される」箇所のみ、原則1行。
- 互換層・ラッパー・フォールバックを足す前に、それが本当に必要かソースで確認すること。

# Edit Rules

**原則として** 既存コードの削除はしないでください。
ただし、当然ながら既存コードを削除・変更をしないと目的が達成できない場合があります。既存コードに削除・変更を加える場合は、必ずなぜ必要なのかを User に説明してから実行してください。
