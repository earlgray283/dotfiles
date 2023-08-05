return {
	{
		"akinsho/bufferline.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nord.nvim",
		},
		opts = function()
			local highlights = require("nord").bufferline.highlights({
				italic = true,
				bold = true,
			})
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
				highlights = highlights,
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
			-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#beauwilliams
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
				pattern = "NvimTree_*",
				callback = function()
					local layout = vim.api.nvim_call_function("winlayout", {})
					if
						layout[1] == "leaf"
						and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
						and layout[3] == nil
					then
						vim.cmd("confirm quit")
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
}
