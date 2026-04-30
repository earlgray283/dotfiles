require("lz.n").load({
  {
    "vim-illuminate",
    event = "BufRead",
    after = function()
      require("illuminate").configure({
        delay           = 100,
        large_file_cutoff = 2000,
        providers       = { "lsp", "treesitter", "regex" },
      })
    end,
  },
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
    "nvim-autopairs",
    event = "InsertEnter",
    after = function()
      require("nvim-autopairs").setup({})
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

-- mini.comment is a start plugin (mini-nvim); set up directly
require("mini.comment").setup({})
