return {
	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		lazy = true,
		cmd = "ConformInfo",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "goimports" },
				rust = { "rustfmt" },
				proto = { "buf" },
				typescript = { { "dprint", "prettier" } },
				typescriptreact = { { "dprint", "prettier" } },
				yaml = { "yamlfmt" },
			},
			formatters = {
				dprint = function()
					return {
						command = require("conform.util").find_executable({
							"node_modules/.bin/dprint",
						}, "dprint"),
					}
				end,
			},
			format_on_save = {
				timeout_ms = 200,
				lsp_fallback = false,
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
