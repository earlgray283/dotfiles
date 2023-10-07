return {
	{
		"gbprod/nord.nvim",
		lazy = false,
		priority = 100000,
		init = function()
			require("nord").setup({})
			vim.cmd([[colorscheme nord]])
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		init = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = {
					enable = true,
					disable = { "yaml", "dockerfile", "make", "html" },
				},
				indent = {
					enable = true,
				},
				autotag = {
					enable = true,
				},
			})
			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
					underline = true,
					virtual_text = {
						spacing = 5,
						severity_limit = "Warning",
				},
					update_in_insert = true,
				})
		end,
	},
}
