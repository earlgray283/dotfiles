local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- code completion
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate"        -- :MasonUpdate updates registry contents
	},
	"williamboman/mason-lspconfig.nvim", -- LSP
	"neovim/nvim-lspconfig",          -- LSP
	"mfussenegger/nvim-dap",          -- DAP
	"jose-elias-alvarez/null-ls.nvim", -- linter, formatter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate"
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
		}
	},

	-- misc
	"folke/which-key.nvim",
	"windwp/nvim-autopairs",
	"L3MON4D3/LuaSnip",

	-- appearance
	"nvim-tree/nvim-tree.lua",  -- sidebar(explorer)
	"nvim-tree/nvim-web-devicons", -- icon
	"akinsho/bufferline.nvim",  -- tab
	"nvim-lualine/lualine.nvim", -- encoding of the file, etc.
	"rcarriga/nvim-notify",     -- notification
	-- terminal
	{
		'akinsho/toggleterm.nvim',
		version = "*",
		config = true
	},

	-- theme
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	"nordtheme/vim"
})

require("nvim-autopairs").setup()
require("nvim-tree").setup()
require("bufferline").setup({
	options = {
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Directory",
				separator = true
			}
		},
	}
})
require('lualine').setup({
	options = {
		-- theme = "catppuccin"
		theme = "nord"
	}
})
require("toggleterm").setup({})
vim.notify = require("notify")

-- load lsp
require("plugins/lsp")
