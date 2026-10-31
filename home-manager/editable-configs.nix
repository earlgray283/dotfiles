{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  claudeSettings = "${home}/.claude/settings.json";
  codexConfig = ".codex/config.toml";
  opencodeConfig = "opencode/opencode.json";
  museConfig = "muse/settings.json";
in
{
  home.file.${claudeSettings}.enable = false;
  home.file.${codexConfig}.enable = false;
  xdg.configFile.${opencodeConfig}.enable = false;
  xdg.configFile.${museConfig}.enable = false;

  home.activation =
    import ../lib/editable-configs.nix
      {
        inherit lib;
        inherit (pkgs) jq;
        stateDir = "${config.xdg.stateHome}/home-manager/editable-configs";
      }
      {
        "claude-settings.json" = {
          inherit (config.home.file.${claudeSettings}) source;
          target = claudeSettings;
        };
        "codex-config.toml" = {
          inherit (config.home.file.${codexConfig}) source;
          target = "${home}/${codexConfig}";
        };
        "opencode.json" = {
          inherit (config.xdg.configFile.${opencodeConfig}) source;
          target = "${config.xdg.configHome}/${opencodeConfig}";
        };
        "muse-settings.json" = {
          inherit (config.xdg.configFile.${museConfig}) source;
          target = "${config.xdg.configHome}/${museConfig}";
        };
      };
}
