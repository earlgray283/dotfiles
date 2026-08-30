{
  config,
  lib,
  pkgs,
  ...
}:

let
  tomlFormat = pkgs.formats.toml { };
  codexMcpServers = lib.mapAttrs (
    name: server:
    lib.hm.mcp.transformMcpServer {
      inherit server;
      exclude = [
        "headers"
        "type"
      ];
      extraTransforms = [
        (value: value // lib.optionalAttrs (value.headers or { } != { }) { http_headers = value.headers; })
        lib.hm.mcp.addType
        (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; })
      ];
    }
  ) config.programs.mcp.servers;
  codexPlugins = lib.listToAttrs (
    map (
      plugin:
      let
        manifest = builtins.fromJSON (builtins.readFile (plugin + "/.codex-plugin/plugin.json"));
      in
      lib.nameValuePair "${manifest.name}@home-manager" { enabled = true; }
    ) config.programs.codex.plugins
  );
in
{
  home.packages = [ pkgs.chezmoi ];

  xdg.configFile."chezmoi/chezmoi.toml".text = ''
    sourceDir = "${config.home.homeDirectory}/dev/dotfiles/chezmoi"
  '';

  home.file."dev/dotfiles/chezmoi/.chezmoitemplates/nix/codex-mcp-servers.toml".source =
    tomlFormat.generate "codex-mcp-servers.toml"
      { mcp_servers = codexMcpServers; };

  home.file."dev/dotfiles/chezmoi/.chezmoitemplates/nix/codex-plugins.toml".source =
    tomlFormat.generate "codex-plugins.toml"
      {
        features.plugins = true;
        plugins = codexPlugins;
      };

  home.activation.chezmoiApply = lib.hm.dag.entryAfter [ "linkGeneration" "miseInstall" ] ''
    run ${lib.getExe pkgs.chezmoi} apply
  '';
}
