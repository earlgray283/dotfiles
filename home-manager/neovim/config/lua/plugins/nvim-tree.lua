require("lz.n").load({
  {
    "nvim-tree.lua",
    cmd  = { "NvimTreeToggle", "NvimTreeRefresh", "NvimTreeFocus" },
    keys = {
      { "<leader>e",  "<Cmd>NvimTreeToggle<CR>",  desc = "Toggle file tree" },
      { "<leader>rr", "<Cmd>NvimTreeRefresh<CR>", desc = "Refresh file tree" },
    },
    after = function()
      require("nvim-tree").setup({
        sync_root_with_cwd  = true,
        update_focused_file = { enable = true },
        diagnostics = {
          enable        = true,
          debounce_delay = 100,
          show_on_dirs  = true,
        },
        modified = { enable = true },
        filters  = {
          dotfiles    = false,
          git_ignored = false,
        },
        filesystem_watchers = {
          enable        = true,
          debounce_delay  = 50,
          ignore_dirs   = { "node_modules", "^.git$" },
        },
      })
    end,
  },
})
