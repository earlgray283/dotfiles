# CLAUDE.md

`CLAUDE.md` はあなたと User で共に育てていくものです。
User の指摘で恒久的な改善が必要だとあなたが判断した場合、`CLAUDE.md` の更新を User に問うてください。

> **編集場所**: このファイルは Nix home-manager で管理されています。
> 直接編集するのではなく、`~/Workspace/nix-dotfiles/home-manager/claude-code/CLAUDE.md` を編集してください。

# General Rules

- Response Language: **Always use Japanese (日本語)**.

# Behavior Rules

- 調査・確認作業は自分でツールを使って実行すること。どうしても自分で確認できない場合のみ User に依頼すること。

# Tools & Workflow

- Primary Tools: You **MUST USE** `serena` and `context7` for specialized tasks.
- Shell Aliases:
    - Use `fd` instead of `find`.
    - Use `rg` instead of `grep`.
- **Do NOT use the Task tool for file/code searches.** Use `fd` and `rg` directly via Bash tool.

# Bash Rules

- **`cd` as a standalone command is ALLOWED** to change the working directory before subsequent commands.
- **Do NOT chain commands starting with `cd`** (e.g. `cd /path && git add ...` is forbidden — breaks permission matching in `settings.json`).
- **Do NOT use `git -C /path`** — use `cd /path` in a prior Bash call instead, for readability.
- Each Bash call must start with the actual command that matches a permission rule (i.e. the command after any `cd` in a chain would not match — hence no chains).

# Coding Rules

- Code comments and identifiers should remain in English unless the project dictates otherwise.

# Edit Rules

**原則として** 既存コードの削除はしないでください。
ただし、当然ながら既存コードを削除・変更をしないと目的が達成できない場合があります。既存コードに削除・変更を加える場合は、必ずなぜ必要なのかを User に説明してから実行してください。
