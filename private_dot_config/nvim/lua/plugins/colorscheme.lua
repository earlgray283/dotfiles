return {
	-- {
	-- 	"gbprod/nord.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {
	-- 		errors = { mode = "fg" },
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("nord").setup(opts)
	-- 		vim.cmd.colorscheme("nord")
	-- 	end,
	-- 	install = {
	-- 		colorscheme = { "nord" },
	-- 	},
	-- },
	-- {
	-- 	"AlexvZyl/nordic.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("nordic").load()
	-- 		vim.cmd.colorscheme("nordic")
	-- 	end,
	-- },
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("nordfox")
		end,
	},
}
