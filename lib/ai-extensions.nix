{
  config,
  lib,
  sources,
}:

let
  claudePluginsOfficial = sources.claudePluginsOfficial or null;
  anthropicSkills = sources.anthropicSkills or null;
  githubSkills = sources.githubSkills or null;
  ponytail = sources.ponytail or null;
  goModernGuidelines = sources.goModernGuidelines or null;
  caveman = sources.caveman or null;
  openaiPlugins = sources.openaiPlugins or null;

  mkNamedPaths =
    source: prefix: names:
    lib.listToAttrs (
      map (name: {
        inherit name;
        value = source + "/${prefix}${name}";
      }) names
    );

  mkSkillLinks =
    source:
    lib.mapAttrsToList (name: _: {
      inherit name;
      value = source + "/" + name;
    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir source));

  googleSkillLinks = lib.attrsToList (
    mkNamedPaths sources.googleSkills "skills/cloud/" config.googleSkillNames
  );

  anthropicSkillLinks = lib.optionals (anthropicSkills != null) (
    lib.filter (skill: !(builtins.elem skill.name config.anthropicExcludedSkillNames)) (
      mkSkillLinks "${anthropicSkills}/skills"
    )
  );

  codexGithubSkillLinks = lib.optionals (githubSkills != null) (
    lib.attrsToList (mkNamedPaths githubSkills "skills/" config.codexGithubSkillNames)
  );

  claudePlugins =
    lib.optionalAttrs (claudePluginsOfficial != null) (
      mkNamedPaths claudePluginsOfficial "plugins/" config.claudeWrappedPluginNames
    )
    // {
      superpowers = sources.superpowersSkills;
    }
    // lib.optionalAttrs (ponytail != null) { inherit ponytail; }
    // lib.optionalAttrs (goModernGuidelines != null) {
      modern-go-guidelines = goModernGuidelines + "/plugin";
    }
    // lib.optionalAttrs (caveman != null) { inherit caveman; };

  codexOpenaiPlugins = lib.optionals (openaiPlugins != null) (
    map (name: openaiPlugins + "/plugins/" + name) config.openaiPluginNames
  );
in
{
  inherit claudePlugins;
  claudeSkills = lib.listToAttrs (googleSkillLinks ++ anthropicSkillLinks);
  codexSkills = lib.listToAttrs (
    mkSkillLinks "${sources.superpowersSkills}/skills" ++ googleSkillLinks ++ codexGithubSkillLinks
  );
  codexPlugins =
    lib.optionals (ponytail != null) [ ponytail ]
    ++ lib.optionals (goModernGuidelines != null) [ (goModernGuidelines + "/plugin") ]
    ++ lib.optionals (caveman != null) [ (caveman + "/plugins/caveman") ]
    ++ codexOpenaiPlugins;
}
