vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.termguicolors = true
opt.number = true -- show line number
opt.autowrite = true -- enable auto write
opt.cursorline = true -- enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.tabstop = 4
opt.shiftwidth = 4
opt.laststatus = 3
