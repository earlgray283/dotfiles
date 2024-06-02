return {
	{
		"mfussenegger/nvim-lint",
		opts = {
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				go = { "golangcilint" },
				proto = { "buf_lint" },
				typescript = { "eslint" },
				typescriptreact = { "eslint" },
			},
		},
		config = function(_, opts)
			require("lint").linters_by_ft = opts.linters_by_ft
			vim.api.nvim_create_autocmd(opts.events, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
}
