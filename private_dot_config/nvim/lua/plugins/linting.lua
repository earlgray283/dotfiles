return {
	{
		"mfussenegger/nvim-lint",
		opts = {
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				go = { "golangcilint" },
				proto = { "buf_lint", "api_linter" },
				typescript = { "eslint" },
				typescriptreact = { "eslint" },
			},
		},
		config = function(_, opts)
			local lint = require("lint")
			lint.linters.api_linter = {
				cmd = "api-linter",
			}
			lint.linters_by_ft = opts.linters_by_ft
			vim.api.nvim_create_autocmd(opts.events, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
