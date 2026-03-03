{ ... }:
{
  programs.nvf.settings.vim.filetree.nvimTree = {
    enable = true;

    mappings = {
      toggle = "<leader>e";
      refresh = "<leader>rr";
    };

    setupOpts = {
      sync_root_with_cwd = true;

      update_focused_file = {
        enable = true;
      };

      diagnostics = {
        enable = true;
        debounce_delay = 100;
        show_on_dirs = true;
      };

      modified = {
        enable = true;
      };

      filters = {
        dotfiles = false;
        git_ignored = false;
      };

      filesystem_watchers = {
        enable = true;
        debounce_delay = 50;
        ignore_dirs = [
          "node_modules"
          "^.git$"
        ];
      };
    };
  };
}
