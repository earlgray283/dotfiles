return {
	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		cmd = "ConformInfo",
		opts = {
			formatters_by_ft = {
				cue = { "cue_fmt" },
				go = { "goimports" },
				just = { "just" },
				lua = { "stylua" },
				proto = { "buf", "clang-format", stop_after_first = true },
				rust = { "rustfmt" },
				toml = { "taplo" },
				typescript = { "dprint", "prettier", stop_after_first = true },
				typescriptreact = { "dprint", "prettier", stop_after_first = true },
				yaml = { "yamlfmt" },
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
						return
					end
					require("conform").format({
						bufnr = args.buf,
						timeout_ms = 5000,
						lsp_format = "never",
						-- async = true,
					})
				end,
			})
			vim.api.nvim_create_user_command("ConformDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = false,
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
