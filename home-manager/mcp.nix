{ ... }:

{
  programs.mcp = {
    enable = true;

    servers = {
      # context7 uses the remote HTTP endpoint (different from the local stdio version in mcp-servers-nix)
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp/oauth";
      };
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

  # Nix-managed MCP servers via mcp-servers-nix
  mcp-servers = {
    programs = {
      sequential-thinking.enable = true;
      filesystem = {
        enable = true;
        args = [ "/Users/earlgray" ];
      };
      serena = {
        enable = true;
        context = "claude-code";
      };
      playwright.enable = true;
    };
  };
}
