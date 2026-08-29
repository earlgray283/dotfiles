# CLAUDE.md

`CLAUDE.md` はあなたと User で共に育てていくものです。
User の指摘で恒久的な改善が必要だとあなたが判断した場合、`CLAUDE.md` の更新を User に問うてください。

> **Claude Code と Codex の最終設定だけが chezmoi、それ以外の AI クライアント構成は Nix home-manager で管理されています。正本以外を直接編集しないでください。**
>
> | 実体 | 所有者 | dotfiles での正本・編集場所 |
> |---|---|---|
> | `~/.claude/settings.json`（Claude Code 最終設定） | chezmoi | `chezmoi/dot_claude/settings.json` |
> | `~/.codex/config.toml`（Codex 最終設定） | chezmoi modify | `chezmoi/dot_codex/modify_config.toml` |
> | `~/.claude/CLAUDE.md` | Home Manager | `home-manager/claude-code/CLAUDE.md` |
> | `~/.claude/hooks/`、パッケージ、プラグイン、marketplace、skills | Home Manager | `home-manager/claude-code/claude-code.nix`、`home-manager/claude-code/hooks/`、`home-manager/ai-extensions.nix` |
> | `~/.codex/AGENTS.md`、hooks、パッケージ、skills | Home Manager | `home-manager/codex.nix`、`home-manager/claude-code/CLAUDE.md`、`home-manager/ai-extensions.nix` |
> | `~/.config/opencode/` の構成 | Home Manager | `home-manager/opencode.nix` |

Claude Code が最終設定を書き換えたときは、`chezmoi diff` で確認してから `chezmoi re-add ~/.claude/settings.json` で正本へ取り込みます。Codex の可変設定は `just apply-dotfiles` が現在の `~/.codex/config.toml` から保持し、MCP 部分だけを更新するため、Codex 用の `re-add` は不要です。MCP のサーバー定義は `home-manager/mcp.nix` だけを編集し、生成された Codex 用 fragment は編集しません。

# General Rules

- Response Language: **Always use Japanese (日本語)**.

# Behavior Rules

- 調査・確認作業は自分でツールを使って実行すること。どうしても自分で確認できない場合のみ User に依頼すること。

# Tools & Workflow

- Primary Tool: You **MUST USE** `context7` for specialized tasks.
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
