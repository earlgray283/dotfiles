-- for nvim-tree.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("plugins")
require("autocmd")
require("keymap")

vim.opt.number = true
vim.opt.clipboard = "unnamedplus"
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.updatetime = 1000 -- fires CursorHold event in 1s.

-- vim.cmd.colorscheme "catppuccin"
vim.cmd.colorscheme "nord"
