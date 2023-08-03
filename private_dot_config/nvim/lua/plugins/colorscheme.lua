return {
	{
		dir = "/Users/earlgray/Workspace/nord.nvim",
		lazy = false,
		priority = 100000,
		init = function()
			vim.api.nvim_create_autocmd("BufEnter", {
				callback = function()
					vim.g.nord_contrast = true
					vim.g.nord_borders = true
					vim.g.nord_disable_background = false
					vim.g.nord_italic = true
					vim.g.nord_uniform_diff_background = true
					vim.g.nord_bold = false
					require("nord").set()
				end,
			})
		end,
	},
}
