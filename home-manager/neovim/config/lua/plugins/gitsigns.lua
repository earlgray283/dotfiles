require("lz.n").load({
  {
    "gitsigns.nvim",
    event = "BufRead",
    after = function()
      require("gitsigns").setup({
        current_line_blame      = true,
        current_line_blame_opts = { delay = 1 },
      })
    end,
  },
})
