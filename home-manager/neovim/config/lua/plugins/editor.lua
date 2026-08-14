require("lz.n").load({
  {
    "grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>S",
        function()
          require("grug-far").open()
        end,
        desc = "Search and replace",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Search current word",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").with_visual_selection()
        end,
        mode = "v",
        desc = "Search current selection",
      },
      {
        "<leader>sp",
        function()
          require("grug-far").open({
            prefills = { paths = vim.fn.expand("%"), search = vim.fn.expand("<cword>") },
          })
        end,
        desc = "Search on current file",
      },
    },
    after = function()
      require("grug-far").setup({})
    end,
  },
  {
    "lazydev.nvim",
    ft = "lua",
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
