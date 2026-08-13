-- oil.nvim must not be lazy-loaded: it hooks BufReadCmd to replace netrw for
-- directories, so it needs to be active before any directory buffer is opened
-- (e.g. `nvim .`), which can happen before any lz.n trigger (cmd/keys/event) fires.
require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "<leader>e", function() require("oil").toggle_float() end, { desc = "Toggle file explorer" })
