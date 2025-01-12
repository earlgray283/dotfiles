return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		config = function()
			require("nvim-ts-autotag").setup({})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		build = "make install_jsregexp",
	},

	{
		"zbirenbaum/copilot-cmp",
		dependencies = {
			{
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				opts = {},
				init = function()
					vim.api.nvim_command(":Copilot disable")
				end,
			},
		},
		config = function()
			require("copilot_cmp").setup()
		end,
		init = function()
			vim.keymap.set("n", "<leader>cd", function()
				vim.api.nvim_command(":Copilot disable")
			end, { desc = "(copilot) disable" })
			vim.keymap.set("n", "<leader>ce", function()
				vim.api.nvim_command(":Copilot enable")
			end, { desc = "(copilot) enable" })
		end,
	},
	{
		"numToStr/Comment.nvim",
		lazy = false,
		opts = {},
	},
}
