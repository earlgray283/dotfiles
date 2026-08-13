require("lz.n").load({
  {
    "nvim-spectre",
    cmd  = { "Spectre" },
    keys = {
      { "<leader>S",  function() require("spectre").toggle() end,                              desc = "Toggle Spectre" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end,   desc = "Search current word" },
      { "<leader>sw", function() require("spectre").open_visual() end,                         mode = "v", desc = "Search current word" },
      { "<leader>sp", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search on current file" },
    },
    after = function()
      require("spectre").setup({
        replace_engine = {
          sed = { cmd = "sed", args = { "-i", "", "-E" } },
        },
      })
    end,
  },
  {
    "lazydev.nvim",
    ft    = "lua",
    after = function()
      require("lazydev").setup({
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      })
    end,
  },
  {
    "openingh.nvim",
    cmd = { "OpenInGHRepo", "OpenInGHFile", "OpenInGHFileLines" },
  },
})

-- mini.comment/pairs/cursorword are submodules of mini-nvim, a start plugin; set up directly
require("mini.comment").setup({})
require("mini.pairs").setup({})
require("mini.cursorword").setup({
  delay = 100,
})
