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
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	},
	"williamboman/mason-lspconfig.nvim", -- LSP
	"neovim/nvim-lspconfig", -- LSP
	"mfussenegger/nvim-dap", -- DAP
	"jose-elias-alvarez/null-ls.nvim", -- linter, formatter

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
		},
	},

	-- misc
	"folke/which-key.nvim",
	"windwp/nvim-autopairs",
	"L3MON4D3/LuaSnip",
	"preservim/nerdcommenter",
	"lewis6991/gitsigns.nvim",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- appearance
	"nvim-tree/nvim-tree.lua", -- sidebar(explorer)
	"nvim-tree/nvim-web-devicons", -- icon
	"akinsho/bufferline.nvim", -- tab
	"nvim-lualine/lualine.nvim", -- encoding of the file, etc.
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	-- terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
	},

	-- theme
	"shaunsingh/nord.nvim",
	"rmehri01/onenord.nvim",
	"AlexvZyl/nordic.nvim",
})

require("nvim-treesitter.configs").setup({
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
})
require("nvim-autopairs").setup()

-- require("gitsigns").setup()

require("plugins/lsp")
require("plugins/appearance")
require("plugins/null-ls")
require("plugins/nvim-cmp")
require("plugins/nvimtree")
require("plugins/telescope")
