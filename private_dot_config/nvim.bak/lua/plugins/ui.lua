return {
	{
		"akinsho/bufferline.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"gbprod/nord.nvim",
		},
		opts = function()
			return {
				options = {
					separator_style = "thin",
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							highlight = "Directory",
							separator = true,
						},
					},
				},
			}
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		opts = {
			sort_by = "case_sensitive",
			renderer = {
				icons = {
					glyphs = {
						git = {
							unstaged = "",
							staged = "",
							renamed = "",
							ignored = "",
						},
					},
				},
			},
			filters = {
				custom = { "node_modules", "^.git$" },
			},
			git = {
				ignore = false, -- show files which are contained in .gitignore
			},
			diagnostics = {
				enable = true,
			},
		},
		init = function()
			-- launch nvim-tree when open nvim
			-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup#open-for-files-and-no-name-buffers
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function(data)
					-- buffer is a real file on the disk
					local real_file = vim.fn.filereadable(data.file) == 1

					-- buffer is a [No Name]
					local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

					if not real_file and not no_name then
						return
					end

					-- open the tree, find the file but don't focus it
					require("nvim-tree.api").tree.toggle({ focus = false, find_file = true })
				end,
			})

			-- close nvim-tree automatically when close all buffers
			-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#ppwwyyxx
			vim.api.nvim_create_autocmd("QuitPre", {
				callback = function()
					local invalid_win = {}
					local wins = vim.api.nvim_list_wins()
					for _, w in ipairs(wins) do
						local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
						if bufname:match("NvimTree_") ~= nil then
							table.insert(invalid_win, w)
						end
					end
					if #invalid_win == #wins - 1 then
						-- Should quit, so we close all invalid windows.
						for _, w in ipairs(invalid_win) do
							vim.api.nvim_win_close(w, true)
						end
					end
				end,
			})
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		lazy = false,
		priority = 100000,
		opts = {
			color_icons = true,
			default = true,
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			options = {
				theme = "nord",
				globalstatus = true,
			},
		},
		init = function()
			require("lualine").setup()
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
		init = function()
			vim.keymap.set("n", "<leader>th", "<Cmd>ToggleTerm direction=horizontal<CR>")
			vim.keymap.set("n", "<leader>tv", "<Cmd>ToggleTerm direction=vertical<CR>")
			vim.keymap.set("n", "<leader>tf", "<Cmd>ToggleTerm direction=float<CR>")
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		init = function()
			vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "lazygit" })
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = false,
					["vim.lsp.util.stylize_markdown"] = false,
					["cmp.entry.get_documentation"] = true,
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		opts = {
			top_down = false,
		},
	},
}
