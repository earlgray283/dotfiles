return {
	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		lazy = true,
		cmd = "ConformInfo",
		opts = {
			formatters_by_ft = {
				go = { "goimports" },
				lua = { "stylua" },
				proto = { "clang-format" },
				rust = { "rustfmt" },
				toml = { "taplo" },
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
					if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
						return
					end
					require("conform").format({ bufnr = args.buf })
				end,
			})
			vim.api.nvim_create_user_command("ConformDisable", function(args)
				-- TODO: support to toggle each buffers
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
			})
			vim.api.nvim_create_user_command("ConformEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
	},
}
