{
  pkgs,
  claude-plugins-official,
  anthropic-skills,
  superpowers-skills,
  google-skills,
  github-skills,
  shadcn-ui,
  ponytail,
  go-modern-guidelines,
  caveman,
  cloudflare-skills,
  openai-plugins,
  ...
}:

let
  aiExtensions = import ../../lib/ai-extensions.nix {
    inherit (pkgs) lib;
    config = import ./extensions.nix;
    sources = {
      claudePluginsOfficial = claude-plugins-official;
      anthropicSkills = anthropic-skills;
      superpowersSkills = superpowers-skills;
      googleSkills = google-skills;
      githubSkills = github-skills;
      shadcnUi = shadcn-ui;
      inherit ponytail caveman;
      cloudflareSkills = cloudflare-skills;
      goModernGuidelines = go-modern-guidelines;
      openaiPlugins = openai-plugins;
      localSkills = ./skills;
    };
  };
in
{
  imports = [
    ./claude.nix
    ./codex.nix
    ./mcp.nix
  ];

  _module.args = { inherit aiExtensions; };
}
