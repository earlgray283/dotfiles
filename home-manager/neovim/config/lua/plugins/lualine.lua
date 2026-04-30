require("lz.n").load({
  {
    "lualine.nvim",
    event = "UIEnter",
    after = function()
      require("lualine").setup({
        options = {
          globalstatus = true,
          theme        = "catppuccin",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { "diagnostics", "filetype", "filename" },
        },
      })
    end,
  },
})
