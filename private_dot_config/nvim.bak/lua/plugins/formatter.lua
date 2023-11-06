return {
	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		lazy = true,
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "goimports" },
				rust = { "rustfmt" },
			},
			format_on_save = {
				timeout_ms = 3000,
				lsp_fallback = true,
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})
		end,
	},
}
