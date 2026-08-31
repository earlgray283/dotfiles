{ ... }:

{
  programs.mcp = {
    enable = true;

    servers = {
      # GitHub Copilot MCP uses a custom URL not available in mcp-servers-nix
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp";
        headers = {
          Authorization = "Bearer {env:API_KEY_GITHUB}";
        };
      };
    };
  };
}
