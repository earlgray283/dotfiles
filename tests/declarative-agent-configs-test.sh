#!/usr/bin/env bash

set -euo pipefail

generation=$(nix build --no-link --print-out-paths path:.#homeConfigurations.earlgray.activationPackage)
editable_source() {
  rg -o --replace '$1' "^deploy_editable $1 (\\S+) " "$generation/activate"
}
claude_config=$(editable_source claude-settings.json)
codex_config=$(editable_source codex-config.toml)
opencode_config=$(editable_source opencode.json)
claude_mcp="$generation/home-files/.claude/skills/claude-code-home-manager/.mcp.json"
claude_skills="$generation/home-files/.claude/skills"
codex_skills="$generation/home-files/.codex/skills"
codex_plugins="$generation/home-files/.codex/plugins/cache/home-manager"

test -f "$claude_config"
test -f "$codex_config"
test -f "$opencode_config"
test ! -e "$generation/home-files/.claude/settings.json"
test ! -e "$generation/home-files/.codex/config.toml"
test ! -e "$generation/home-files/.config/opencode/opencode.json"
rg -qF 'editableConfigsCheck' "$generation/activate"

jq -e '
  .model == "sonnet"
  and .effortLevel == "medium"
  and .autoUpdatesChannel == "latest"
  and .includeCoAuthoredBy == true
  and .permissions.defaultMode == "auto"
  and (.hooks.SessionStart | length == 1)
' "$claude_config"

rg -qF 'model = "gpt-5.6-sol"' "$codex_config"
rg -qF 'service_tier = "default"' "$codex_config"
rg -qF '[mcp_servers.github]' "$codex_config"
rg -qF '[plugins."ponytail@home-manager"]' "$codex_config"
rg -qF '[hooks.state."ponytail@home-manager:hooks/claude-codex-hooks.json:session_start:0:0"]' "$codex_config"
jq -e '.mcpServers.github.url == "https://api.githubcopilot.com/mcp"' "$claude_mcp"

google_skills=(
  cloud-run-basics
  firebase-basics
  gke-basics
  gke-cluster-creation
  gke-manifest-generation
  gke-networking
  gke-storage
  gke-upgrades
  gke-workload-scaling
  gke-workload-security
  gke-workload-troubleshooting
  spanner-basics
)

for skill in "${google_skills[@]}"; do
  test -e "$claude_skills/$skill/SKILL.md"
  test -e "$codex_skills/$skill/SKILL.md"
done

test ! -e "$claude_skills/bigquery-basics"
test ! -e "$codex_skills/bigquery-basics"

test -e "$claude_skills/academy-guide/SKILL.md"
test -e "$claude_skills/mcp-builder/SKILL.md"
test ! -e "$codex_skills/academy-guide"
test ! -e "$codex_skills/mcp-builder"

for plugin in figma linear notion codex-security openai-developers; do
  test -d "$codex_plugins/$plugin"
done

for skill in cli-creator figma-use gh-address-comments gh-fix-ci linear \
  notion-knowledge-capture notion-research-documentation \
  notion-spec-to-implementation pdf security-best-practices; do
  test ! -e "$codex_skills/$skill"
done

test -e "$codex_skills/security-review/SKILL.md"
test -e "$claude_skills/ai-management/SKILL.md"
test -e "$codex_skills/ai-management/SKILL.md"
