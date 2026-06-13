require("lz.n").load({
  {
    "which-key.nvim",
    event = "UIEnter",
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer keymaps",
      },
    },
    after = function()
      local wk = require("which-key")
      wk.setup({
        plugins = {
          presets = {
            operators    = true, -- d/y/c などの後に使えるモーションを表示
            motions      = true, -- w/b/e などのモーションを表示
            text_objects = true, -- a/i の後にテキストオブジェクト一覧を表示
            windows      = true, -- <C-w> コマンド一覧
            z            = true, -- z コマンド一覧（fold, spell 等）
            g            = true, -- g コマンド一覧
          },
        },
      })
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
