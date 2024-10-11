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
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					vim.notify("disabled")
					return
				end
				return { timeout_ms = 200, lsp_format = "never" }
			end,
		},
		init = function()
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
