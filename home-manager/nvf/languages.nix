{ pkgs, ... }:
{
  programs.nvf.settings.vim.lsp = {
    enable = true;
    lspkind = {
      enable = true;
    };
    lspconfig = {
      enable = true;
    };
    servers.nixd.settings.nixd.options."home-manager".expr =
      ''(builtins.getFlake (builtins.toString ./.)).homeConfigurations."earlgray".options'';
  };

  programs.nvf.settings.vim.languages = {
    enableTreesitter = true;
    enableFormat = true;
    enableExtraDiagnostics = true;

    go = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      format = {
        enable = true;
        type = [ "gofmt" ];
      };
      extraDiagnostics.enable = true;
    };

    rust = {
      enable = true;
      lsp = {
        enable = true;
        package = pkgs.rust-analyzer;
      };
      treesitter.enable = true;
    };

    ts = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      format.enable = true;
    };

    lua = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      format.enable = true;
    };

    nix = {
      enable = true;
      lsp = {
        enable = true;
        servers = [ "nixd" ];
      };
      treesitter.enable = true;
      format = {
        enable = true;
        type = [ "nixfmt" ];
      };
    };

    css = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };

    yaml = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };

    terraform = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };

    toml = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };

    html = {
      enable = true;
      treesitter.enable = true;
    };

    markdown = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };
  };
}
