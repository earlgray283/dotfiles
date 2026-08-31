{
  pkgs,
  claude-plugins-official ? null,
  anthropic-skills ? null,
  superpowers-skills,
  google-skills,
  github-skills ? null,
  ponytail ? null,
  go-modern-guidelines ? null,
  caveman ? null,
  openai-plugins ? null,
}:

let
  inherit (pkgs) lib;

  wrappedPlugins = lib.optionalAttrs (claude-plugins-official != null) {
    frontend-design = claude-plugins-official + "/plugins/frontend-design";
    code-simplifier = claude-plugins-official + "/plugins/code-simplifier";
    skill-creator = claude-plugins-official + "/plugins/skill-creator";
    claude-md-management = claude-plugins-official + "/plugins/claude-md-management";
    security-guidance = claude-plugins-official + "/plugins/security-guidance";
    commit-commands = claude-plugins-official + "/plugins/commit-commands";
    claude-code-setup = claude-plugins-official + "/plugins/claude-code-setup";
    gopls-lsp = claude-plugins-official + "/plugins/gopls-lsp";
    rust-analyzer-lsp = claude-plugins-official + "/plugins/rust-analyzer-lsp";
  };

  nativePlugins = {
    superpowers = superpowers-skills;
  }
  // lib.optionalAttrs (ponytail != null) { inherit ponytail; }
  // lib.optionalAttrs (go-modern-guidelines != null) {
    modern-go-guidelines = go-modern-guidelines + "/plugin";
  }
  // lib.optionalAttrs (caveman != null) {
    inherit caveman;
  };

  codexGithubSkillNames = [
    "git-commit"
    "github-issues"
    "github-release"
    "premium-frontend-ui"
    "security-review"
    "refactor"
    "breakdown-feature-implementation"
  ];

  codexGithubSkillLinks = lib.optionals (github-skills != null) (
    map (name: {
      inherit name;
      value = github-skills + "/skills/" + name;
    }) codexGithubSkillNames
  );

  googleSkillNames = [
    "cloud-run-basics"
    "firebase-basics"
    "gke-basics"
    "gke-cluster-creation"
    "gke-manifest-generation"
    "gke-networking"
    "gke-storage"
    "gke-upgrades"
    "gke-workload-scaling"
    "gke-workload-security"
    "gke-workload-troubleshooting"
    "spanner-basics"
  ];

  mkSelectedSkillLinks =
    source: names:
    (map (name: {
      inherit name;
      value = source + "/" + name;
    }) names);

  mkSkillLinks =
    source:
    lib.mapAttrsToList (name: _: {
      inherit name;
      value = source + "/" + name;
    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir source));

  googleSkillLinks = mkSelectedSkillLinks "${google-skills}/skills/cloud" googleSkillNames;

  anthropicSkillLinks = lib.optionals (anthropic-skills != null) (
    lib.filter (
      skill:
      !(builtins.elem skill.name [
        "frontend-design"
        "skill-creator"
      ])
    ) (mkSkillLinks "${anthropic-skills}/skills")
  );

  claudeSkills = lib.listToAttrs (googleSkillLinks ++ anthropicSkillLinks);

  codexSkills = lib.listToAttrs (
    mkSkillLinks "${superpowers-skills}/skills" ++ googleSkillLinks ++ codexGithubSkillLinks
  );

  openaiPluginNames = [
    "codex-security"
    "figma"
    "linear"
    "notion"
    "openai-developers"
  ];

  codexOpenaiPlugins = lib.optionals (openai-plugins != null) (
    map (name: openai-plugins + "/plugins/" + name) openaiPluginNames
  );

  codexPlugins =
    lib.optionals (ponytail != null) [ ponytail ]
    ++ lib.optionals (go-modern-guidelines != null) [ (go-modern-guidelines + "/plugin") ]
    ++ lib.optionals (caveman != null) [ (caveman + "/plugins/caveman") ]
    ++ codexOpenaiPlugins;
in
{
  claudePlugins = wrappedPlugins // nativePlugins;
  inherit claudeSkills codexPlugins codexSkills;
}
