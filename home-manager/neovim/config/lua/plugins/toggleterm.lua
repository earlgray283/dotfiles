require("lz.n").load({
  {
    "toggleterm.nvim",
    cmd  = { "ToggleTerm", "ToggleTermToggleAll" },
    keys = {
      { "<leader>th", "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle horizontal terminal" },
      { "<leader>t1", "<Cmd>1ToggleTerm direction=horizontal<CR>", desc = "Toggle terminal 1" },
      { "<leader>t2", "<Cmd>2ToggleTerm direction=horizontal<CR>", desc = "Toggle terminal 2" },
      { "<leader>t3", "<Cmd>3ToggleTerm direction=horizontal<CR>", desc = "Toggle terminal 3" },
      { "<leader>gg", function()
          require("toggleterm.terminal").Terminal
            :new({ cmd = "lazygit", direction = "float", hidden = true })
            :toggle()
        end, desc = "Toggle lazygit" },
    },
    after = function()
      require("toggleterm").setup({
        shade_terminals = false,
      })
    end,
  },
})
