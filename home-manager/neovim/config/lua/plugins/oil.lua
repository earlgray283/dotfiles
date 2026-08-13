require("lz.n").load({
  {
    "oil.nvim",
    cmd  = { "Oil" },
    keys = {
      { "<leader>e", function() require("oil").toggle_float() end, desc = "Toggle file explorer" },
    },
    after = function()
      require("oil").setup({
        default_file_explorer = false,
        view_options = {
          show_hidden = true,
        },
      })
    end,
  },
})
