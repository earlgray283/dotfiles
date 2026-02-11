{ ... }:

{
  programs.mcp = {
    enable = true;

    servers = {
      fetch = {
        type = "stdio";
        command = "uvx";
        args = [
          "mcp-server-fetch"
        ];
        env = { };
      };
      sequential-thinking = {
        type = "stdio";
        command = "bunx";
        args = [
          "@modelcontextprotocol/server-sequential-thinking"
        ];
        env = { };
      };
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp/oauth";
      };
    };
  };
}
