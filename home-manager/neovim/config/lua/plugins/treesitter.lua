-- Use neovim built-in treesitter (0.10+); nvim-treesitter plugin kept for grammars/plugin deps only
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

require("lz.n").load({
  {
    "nvim-treesitter-context",
    event = "BufRead",
    after = function()
      require("treesitter-context").setup({})
    end,
  },
  {
    "nvim-treesitter-textobjects",
    event = "BufRead",
  },
  {
    "nvim-ts-autotag",
    ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "xml" },
    after = function()
      require("nvim-ts-autotag").setup({})
    end,
  },
})
