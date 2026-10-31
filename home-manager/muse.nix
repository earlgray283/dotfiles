{ config, lib, ... }:

let
  # Muse reads ${VAR} where the shared MCP definition uses OpenCode's {env:VAR}.
  museEnv = lib.replaceStrings [ "{env:" "}" ] [ "\${" "}" ];

  toMuseServer =
    server:
    if server ? url then
      {
        transport = "streamable_http";
        inherit (server) url;
        headers = lib.mapAttrs (_: museEnv) (server.headers or { });
        mode = "optional";
      }
    else
      {
        transport = "stdio";
        inherit (server) command;
        args = server.args or [ ];
        env = lib.mapAttrs (_: museEnv) (server.env or { });
        mode = "optional";
      };
in
{
  xdg.configFile."muse/settings.json".text = builtins.toJSON {
    schema_version = 1;
    mcp_servers = lib.mapAttrs (_: toMuseServer) config.programs.mcp.servers;
  };
}
