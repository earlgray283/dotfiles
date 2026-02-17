{ inputs, pkgs, ... }:
{
  programs.nvf.settings.vim = {
    statusline.lualine = {
      enable = true;
      globalStatus = true;
      theme = "catppuccin";
      setupOpts.sections = {
        lualine_a = [ [ "mode" ] ];
        lualine_b = [ [ "branch" ] ];
        lualine_c = [
          [ "diagnostics" ]
          [ "filetype" ]
          [ "filename" ]
        ];
      };
    };

    telescope = {
      enable = true;
      setupOpts.defaults.preview.treesitter = false;
      setupOpts.pickers.git_status.preview.treesitter = false;
      extensions = [
        {
          name = "fzf";
          packages = [
            pkgs.vimPlugins.telescope-fzf-native-nvim
            pkgs.vimPlugins.telescope-file-browser-nvim
          ];
          setup = {
            fzf = {
              fuzzy = true;
              override_generic_sorter = true;
              override_file_sorter = true;
            };
            file_browser = {
            };
          };
        }
      ];
      mappings = {
        findFiles = "<leader>ff";
        liveGrep = "<leader>/";
        buffers = "<leader>fb";
        helpTags = "<leader>fh";
        diagnostics = "<leader>fd";
        gitStatus = "<leader>fs";
      };
    };

    git.gitsigns = {
      enable = true;
      setupOpts = {
        current_line_blame = true;
        current_line_blame_opts.delay = 1;
      };
    };

    visuals.nvim-web-devicons = {
      enable = true;
    };
  };
}
