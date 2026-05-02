require("lz.n").load({
  {
    "which-key.nvim",
    event = "UIEnter",
    after = function()
      local wk = require("which-key")
      wk.setup({})
      wk.add({
        { "<leader>c", group = "claude" },
        { "<leader>f", group = "find" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "terminal" },
        { "<leader>r", group = "refresh" },
      })
    end,
  },
})
