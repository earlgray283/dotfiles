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
in
{
  home.packages = [ pkgs.chezmoi ];

  xdg.configFile."chezmoi/chezmoi.toml".text = ''
    sourceDir = "${config.home.homeDirectory}/dev/dotfiles/chezmoi"
  '';

  home.file."dev/dotfiles/chezmoi/.chezmoitemplates/nix/codex-mcp-servers.toml".source =
    tomlFormat.generate "codex-mcp-servers.toml"
      { mcp_servers = codexMcpServers; };
}
