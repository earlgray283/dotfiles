return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
		dependencies = "hrsh7th/nvim-cmp",
		init = function()
			-- insert `(` after select function or method item
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		init = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = {
					enable = true,
					disable = { "yaml", "dockerfile", "make" },
				},
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			local wk = require("which-key")
			wk.register(mappings, opts)
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "*",
		dependencies = { "nvim-lua/plenary.nvim" },
		init = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[telescope] find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[telescope] live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[telescope] search from buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[telescope] help tags" })
		end,
		opts = {
			pickers = {
				find_files = {
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
				live_grep = {
					additional_args = function(opts)
						return { "--hidden" }
					end,
				},
			},
		},
	},
	{
		"github/copilot.vim",
		init = function()
			vim.g.copilot_enabled = false
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		init = function()
			vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "lazygit" })
		end,
	},
}
