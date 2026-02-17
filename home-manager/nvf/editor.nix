{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    # toggleterm + lazygit
    terminal.toggleterm = {
      enable = true;
      setupOpts.shade_terminals = false;
      lazygit = {
        enable = true;
        mappings.open = "<leader>gg";
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      # vim-illuminate: シンボルハイライト
      vim-illuminate = {
        package = vim-illuminate;
        setup = ''
          require('illuminate').configure({
            delay = 100,
            large_file_cutoff = 2000,
            providers = { "lsp", "treesitter", "regex" },
          })
        '';
      };

      # SchemaStore: yamlls/jsonls 用スキーマ (setup は lsp-overrides.nix で行う)
      SchemaStore-nvim = {
        package = SchemaStore-nvim;
      };

      # nvim-spectre: Find and Replace
      nvim-spectre = {
        package = nvim-spectre;
        setup = ''
          require('spectre').setup({
            replace_engine = {
              sed = { cmd = "sed", args = { "-i", "", "-E" } },
            },
          })
        '';
      };

      # openingh: GitHub 連携
      openingh-nvim = {
        package = openingh-nvim;
      };
    };
  };
}
