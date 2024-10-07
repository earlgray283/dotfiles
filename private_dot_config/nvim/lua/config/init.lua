vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.termguicolors = true
opt.number = true -- show line number
opt.autowrite = true -- enable auto write
opt.cursorline = true -- enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.laststatus = 3
opt.swapfile = false
opt.autoread = true
opt.splitright = true

-- indentation
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 2
opt.shiftwidth = 0
opt.expandtab = true

vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>")

vim.api.nvim_set_keymap("n", "<Space>", "<NOP>", { noremap = true, silent = true })
vim.g.mapleader = " " -- leaderキーを<Space>に設定する

vim.filetype.add({
	pattern = {
		[".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
		[".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
	},
})
