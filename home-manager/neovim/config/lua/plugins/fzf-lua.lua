require("lz.n").load({
  {
    "fzf-lua",
    cmd = { "FzfLua" },
    keys = {
      { "<leader>ff", function() require("fzf-lua").files() end,                   desc = "Find files" },
      { "<leader>/",  function() require("fzf-lua").live_grep() end,               desc = "Live grep" },
      { "<leader>fb", function() require("fzf-lua").buffers() end,                 desc = "Buffers" },
      { "<leader>fh", function() require("fzf-lua").helptags() end,                desc = "Help tags" },
      { "<leader>fd", function() require("fzf-lua").diagnostics_workspace() end,   desc = "Diagnostics" },
      { "<leader>fs", function() require("fzf-lua").git_status() end,              desc = "Git status" },
      { "<leader>fk", function() require("fzf-lua").keymaps() end,                 desc = "Keymaps" },
    },
    after = function()
      require("fzf-lua").setup({
        winopts = {
          border = "single",
          preview = {
            border = "single",
          },
        },
      })
    end,
  },
})
