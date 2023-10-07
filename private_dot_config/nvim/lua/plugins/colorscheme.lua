return {
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		priority = 100000,
		init = function()
			vim.g.nord_contrast = true
			vim.g.nord_borders = true
			vim.g.nord_disable_background = false
			vim.g.nord_italic = true
			vim.g.nord_uniform_diff_background = true
			vim.g.nord_bold = false
			require("nord").set()
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
