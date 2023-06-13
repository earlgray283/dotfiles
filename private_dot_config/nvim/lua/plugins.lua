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

	-- theme
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }
})

require("mason").setup()
require("mason-lspconfig").setup()
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
		theme = "catppuccin"
	}
})

require("lspconfig").lua_ls.setup({})
require("lspconfig").rust_analyzer.setup({})

-- Set up nvim-cmp.
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, {
		{ name = 'buffer' },
	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})
