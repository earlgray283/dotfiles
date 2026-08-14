-- not lazy-loaded: must be active before any directory buffer opens (e.g. `nvim .`)
require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "<leader>e", function()
  require("oil").toggle_float()
end, { desc = "Toggle file explorer" })
