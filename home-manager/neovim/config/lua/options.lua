vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

for _, plugin in ipairs({
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
}) do
  vim.g["loaded_" .. plugin] = 1
end

vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.laststatus = 3
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.splitright = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0
vim.opt.winborder = "single"
