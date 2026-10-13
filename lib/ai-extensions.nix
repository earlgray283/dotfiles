{
  config,
  lib,
  sources,
}:

let
  claudePluginsOfficial = sources.claudePluginsOfficial or null;
  anthropicSkills = sources.anthropicSkills or null;
  githubSkills = sources.githubSkills or null;
  shadcnUi = sources.shadcnUi or null;
  ponytail = sources.ponytail or null;
  goModernGuidelines = sources.goModernGuidelines or null;
  caveman = sources.caveman or null;
  openaiPlugins = sources.openaiPlugins or null;
  localSkills = sources.localSkills or null;

  copyPath =
    kind: name: path:
    builtins.path {
      inherit path;
      name = "ai-${kind}-${name}";
    };

  mkNamedPaths =
    kind: source: prefix: names:
    lib.listToAttrs (
      map (name: {
        inherit name;
        value = copyPath kind name (source + "/${prefix}${name}");
      }) names
    );

  mkSkillLinks =
    provider: source:
    lib.mapAttrsToList (name: _: {
      inherit name;
      value = copyPath "skill-${provider}" name (source + "/${name}");
    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir source));

  mkDirectSkillLinks =
    source:
    lib.mapAttrsToList (name: _: {
      inherit name;
      value = "${source}/${name}";
    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir source));

  googleSkillLinks = lib.attrsToList (
    mkNamedPaths "skill-google" sources.googleSkills "skills/cloud/" config.googleSkillNames
  );

  anthropicSkillLinks = lib.optionals (anthropicSkills != null) (
    lib.filter (skill: !(builtins.elem skill.name config.anthropicExcludedSkillNames)) (
      mkSkillLinks "anthropic" "${anthropicSkills}/skills"
    )
  );

  codexGithubSkillLinks = lib.optionals (githubSkills != null) (
    lib.attrsToList (mkNamedPaths "skill-github" githubSkills "skills/" config.codexGithubSkillNames)
  );

  shadcnSkillLinks = lib.optionals (shadcnUi != null) (
    lib.attrsToList (mkNamedPaths "skill-shadcn" shadcnUi "skills/" config.shadcnSkillNames)
  );

  localSkillLinks = lib.optionals (localSkills != null) (mkDirectSkillLinks localSkills);
  localSkillAttrs = lib.listToAttrs localSkillLinks;

  claudePlugins =
    lib.optionalAttrs (claudePluginsOfficial != null) (
      mkNamedPaths "plugin-claude" claudePluginsOfficial "plugins/" config.claudeWrappedPluginNames
    )
    // {
      superpowers = copyPath "plugin" "superpowers" sources.superpowersSkills;
    }
    // lib.optionalAttrs (ponytail != null) {
      ponytail = copyPath "plugin" "ponytail" ponytail;
    }
    // lib.optionalAttrs (goModernGuidelines != null) {
      modern-go-guidelines = copyPath "plugin" "modern-go-guidelines" (goModernGuidelines + "/plugin");
    }
    // lib.optionalAttrs (caveman != null) {
      caveman = copyPath "plugin" "caveman" caveman;
    };

  codexOpenaiPlugins = lib.optionals (openaiPlugins != null) (
    map (
      name: copyPath "plugin-openai" name (openaiPlugins + "/plugins/" + name)
    ) config.openaiPluginNames
  );
in
{
  inherit claudePlugins;
  claudeSkills = lib.listToAttrs (googleSkillLinks ++ anthropicSkillLinks ++ shadcnSkillLinks) // localSkillAttrs;
  codexSkills =
    lib.listToAttrs (
      mkSkillLinks "superpowers" "${sources.superpowersSkills}/skills"
      ++ googleSkillLinks
      ++ codexGithubSkillLinks
      ++ shadcnSkillLinks
    )
    // localSkillAttrs;
  codexPlugins =
    lib.optionals (ponytail != null) [ (copyPath "plugin" "ponytail" ponytail) ]
    ++ lib.optionals (goModernGuidelines != null) [
      (copyPath "plugin" "modern-go-guidelines" (goModernGuidelines + "/plugin"))
    ]
    ++ lib.optionals (caveman != null) [
      (copyPath "plugin" "caveman" (caveman + "/plugins/caveman"))
    ]
    ++ codexOpenaiPlugins;
}
