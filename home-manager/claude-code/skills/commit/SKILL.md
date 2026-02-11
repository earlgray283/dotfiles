---
name: commit
description: Commit the changes on git
---

## Commit Rules

- 英語でコミットすること

### 修正が軽微の場合

特定の package にちょっとした修正を加えたり、新たな package を追加した場合はこのルールを適用してください

#### Commit Message の形式

```
<scope>: <summary>
```

scope: 変更のスコープ(e.g. claude-code, ghostty, etc.)
summary: 変更のサマリ

### 複数の修正がある場合

※ ほとんどこの Rule は適用されないはず

大規模なリファクタリングを行ったり、lint で厳格なルールを適用して複数のファイルの修正が発生した場合、それらをまとめて Summary を生成してコミットしてください。
