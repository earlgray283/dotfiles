---
name: ai-management
description: Manage Claude Code and Codex models, settings, MCP servers, plugins, and skills in this dotfiles repository.
---

# AI Management

Edit only the canonical source for the requested change:

- Claude Code model, permissions, or hooks: `home-manager/ai/claude.nix`
- Codex model, approvals, trust, or hooks: `home-manager/ai/codex.nix`
- MCP server shared by clients: `home-manager/ai/mcp.nix`
- External plugin or Skill selection: `home-manager/ai/extensions.nix` and its flake input
- New or improved local Skill: `home-manager/ai/skills/<name>/SKILL.md`
- Shared agent instructions: `home-manager/ai/instructions.md`
- CLI installation or update commands: `lib/official-ai-installers.nix` and `justfile`

Never edit generated files under `~/.claude`, `~/.codex`, or the Nix store. Run `just test-ai`, then use `just switch-home-manager` only when the user requests applying the configuration. Use `just install-ai` only when the user requests installing or updating both CLIs.
