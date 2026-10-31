{
  config,
  lib,
  sources,
}:

let
  opt = name: f: lib.optionalAttrs (sources ? ${name}) (f sources.${name});
  optList = name: f: lib.optional (sources ? ${name}) (f sources.${name});

  copyPath =
    kind: name: path:
    builtins.path {
      inherit path;
      name = "ai-${kind}-${name}";
    };
  plugin = copyPath "plugin";

  picked =
    kind: source: prefix: names:
    lib.genAttrs names (name: copyPath kind name (source + "/${prefix}${name}"));

  subdirs =
    source: lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir source));

  allSkills =
    provider: source:
    lib.genAttrs (subdirs source) (name: copyPath "skill-${provider}" name (source + "/${name}"));

  googleSkills = picked "skill-google" sources.googleSkills "skills/cloud/" config.googleSkillNames;
  shadcnSkills = opt "shadcnUi" (s: picked "skill-shadcn" s "skills/" config.shadcnSkillNames);
  localSkills = opt "localSkills" (s: lib.genAttrs (subdirs s) (name: "${s}/${name}"));
in
{
  claudePlugins =
    opt "claudePluginsOfficial" (s: picked "plugin-claude" s "plugins/" config.claudeWrappedPluginNames)
    // {
      superpowers = plugin "superpowers" sources.superpowersSkills;
    }
    // opt "ponytail" (s: {
      ponytail = plugin "ponytail" s;
    })
    // opt "goModernGuidelines" (s: {
      modern-go-guidelines = plugin "modern-go-guidelines" (s + "/plugin");
    })
    // opt "caveman" (s: {
      caveman = plugin "caveman" s;
    })
    // opt "cloudflareSkills" (s: {
      cloudflare = plugin "cloudflare" s;
    });

  claudeSkills =
    shadcnSkills
    // opt "anthropicSkills" (
      s: removeAttrs (allSkills "anthropic" (s + "/skills")) config.anthropicExcludedSkillNames
    )
    // googleSkills
    // localSkills;

  codexSkills =
    shadcnSkills
    // opt "githubSkills" (s: picked "skill-github" s "skills/" config.codexGithubSkillNames)
    // googleSkills
    // allSkills "superpowers" (sources.superpowersSkills + "/skills")
    // localSkills;

  codexPlugins =
    optList "ponytail" (plugin "ponytail")
    ++ optList "goModernGuidelines" (s: plugin "modern-go-guidelines" (s + "/plugin"))
    ++ optList "caveman" (s: plugin "caveman" (s + "/plugins/caveman"))
    ++ optList "cloudflareSkills" (plugin "cloudflare")
    ++ lib.optionals (sources ? openaiPlugins) (
      map (
        name: copyPath "plugin-openai" name (sources.openaiPlugins + "/plugins/" + name)
      ) config.openaiPluginNames
    );
}
