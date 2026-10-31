# AGENTS.md / CLAUDE.md

この指示はあなたと User で共に育てていくものです。
User の指摘で恒久的な改善が必要だと判断した場合、この正本の更新を User に問うてください。

Claude Code・Codex・OpenCodeの設定・指示・Skill・MCPの正本は`~/dev/dotfiles`（Home Manager）です。
`settings.json`などの設定ファイルは編集できますが、恒久的な変更は正本へ記述してください。Nix storeと`~/.claude/skills`・`~/.codex/skills`は直接編集しません。
所有者表と編集場所は`~/dev/dotfiles/ARCHITECTURE.md`を参照してください。
この指示ファイル自体の正本は`~/dev/dotfiles/home-manager/ai/instructions.md`です。

# General Rules

- Response Language: **Always use Japanese (日本語)**. Skill・pluginの出力例が英語でも同じ。

# Behavior Rules

- 調査・確認作業は自分でツールを使って実行すること。どうしても自分で確認できない場合のみ User に依頼すること。
- 完了の基準は「実際に動いた」こと。型検査とビルドで終えず自分で実行し、失敗や未実施はそのまま報告する。動作確認を User に頼まない。
- UIの変更はブラウザで操作して確認する。スマホ幅も見る。
- 動かせるものを作ったら、完了報告に実行コマンドを書く。渡すコマンドは実在と動作を確認し、できなければ未確認と書く。
- 依頼された到達点まで進める。仕様やマイルストーンの区切りで止めない。
- 質問の前に推測する。文脈で決まることは聞かず、仮定を1行書いて進める。Skillが質問を促しても同じ。聞くのは結果が大きく変わる分岐か、取り消しにくい操作だけ。
- 依頼された操作が失敗したら、別の操作（pushの拒否に対するrebaseなど）へ広げず、止めて報告する。
- secret（`.env`、鍵JSON、tokenなど）は読まない・表示しない。中身の確認が要るときは User に頼む。
- 案を比べるときは as-is / to-be で示す。

# Tools & Workflow

- Required CLI Tools:
    - **ALWAYS use `fd` instead of `find`. NEVER use `find`.**
    - **ALWAYS use `rg` instead of `grep`. NEVER use `grep`.**
- **Do NOT use the Agent tool for file/code searches.** Use `fd` and `rg` directly via Bash tool.
- **GitHub contents access**: Use `gh` command (e.g. `gh api`, `gh repo view`) instead of `WebFetch` for GitHub URLs.
- CLIは原則miseで導入する（`~/dev/dotfiles/mise/mise.toml`）。

# Bash Rules

- **Do NOT use `git -C /path`** — use `cd /path` in a prior Bash call instead, for readability.
- **パイプの終了コードは `$pipestatus[1]`** — zsh なので `$?` はパイプ最終段の結果になる（`PIPESTATUS` は空）。`cmd | tail` で成否を判定しないこと。

# Coding Rules

- Code comments and identifiers should remain in English unless the project dictates otherwise.
- Git commit messages (subject and body) must be written in English, even though responses to the User are in Japanese.
- コード内コメントはWhy notだけ。package docや処理の説明は書かない。理由・計測値・トレードオフはコミットメッセージへ。残すのは「無いと誤って修正される」箇所のみ、原則1行。
- 自作の前に既存ライブラリを探す。
- フロントエンドはTypeScript/TSXのみ。
- UIは実装前に見た目と情報の優先順位を決める。詰め込まず、アイコンと色で整理する。
- 互換層・ラッパー・フォールバックを足す前に、それが本当に必要かソースで確認すること。

# Edit Rules

**原則として** 既存コードの削除はしないでください。
ただし、目的の達成に必要な削除・変更は行ってかまいません。依頼の範囲内なら理由を1行述べて実行し、確認を待ちません。範囲外の削除だけ User に確認してください。
