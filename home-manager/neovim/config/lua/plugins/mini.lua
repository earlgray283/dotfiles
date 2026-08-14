-- mini.nvim is already a start plugin, so each module here costs only its own
-- load. That makes it cheaper than the standalone plugins it replaces:
-- mini.icons for nvim-web-devicons + lspkind, mini.statusline for lualine.
-- oil, fzf-lua and which-key all probe for mini.icons ahead of
-- nvim-web-devicons, so setting it up is enough; no mock_nvim_web_devicons().
require("mini.icons").setup()

require("mini.statusline").setup({ use_icons = true })

-- No mini.comment: gc/gcc and the gc textobject are built in since 0.10.
require("mini.pairs").setup({})
require("mini.cursorword").setup({
  delay = 100,
})
