{
  pkgs,
  claude-plugins-official ? null,
  superpowers-skills,
  claude-mem,
  google-skills,
  github-skills ? null,
  ponytail ? null,
  go-modern-guidelines ? null,
  caveman ? null,
}:

let
  inherit (pkgs) lib;

  wrappedPlugins = lib.optionalAttrs (claude-plugins-official != null) {
    frontend-design = claude-plugins-official + "/plugins/frontend-design";
    code-review = claude-plugins-official + "/plugins/code-review";
    code-simplifier = claude-plugins-official + "/plugins/code-simplifier";
    skill-creator = claude-plugins-official + "/plugins/skill-creator";
    feature-dev = claude-plugins-official + "/plugins/feature-dev";
    claude-md-management = claude-plugins-official + "/plugins/claude-md-management";
    ralph-loop = claude-plugins-official + "/plugins/ralph-loop";
    security-guidance = claude-plugins-official + "/plugins/security-guidance";
    commit-commands = claude-plugins-official + "/plugins/commit-commands";
    claude-code-setup = claude-plugins-official + "/plugins/claude-code-setup";
    gopls-lsp = claude-plugins-official + "/plugins/gopls-lsp";
    rust-analyzer-lsp = claude-plugins-official + "/plugins/rust-analyzer-lsp";
  };

  nativePlugins = {
    superpowers = superpowers-skills;
    claude-mem = claude-mem;
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

  mkSkillLinks =
    source:
    lib.mapAttrsToList (name: _: {
      inherit name;
      value = source + "/" + name;
    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir source));

  codexSkills = lib.listToAttrs (
    mkSkillLinks "${superpowers-skills}/skills"
    ++ mkSkillLinks "${google-skills}/skills/cloud"
    ++ codexGithubSkillLinks
  );

  codexPlugins =
    lib.optionals (ponytail != null) [ ponytail ]
    ++ lib.optionals (go-modern-guidelines != null) [ (go-modern-guidelines + "/plugin") ]
    ++ lib.optionals (caveman != null) [ (caveman + "/plugins/caveman") ];
in
{
  claudePlugins = wrappedPlugins // nativePlugins;
  skills = "${google-skills}/skills/cloud";
  inherit codexPlugins codexSkills;
}
