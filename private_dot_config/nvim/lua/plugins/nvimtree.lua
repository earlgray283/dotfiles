require("nvim-tree").setup({
	renderer = {
		icons = {
			webdev_colors = true,
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
})

require("nvim-web-devicons").setup({
	override = {
		default = true,
		strict = true,
		override_by_extension = {
			["rs"] = {
				icon = "",
			},
			["go"] = {
				icon = "",
			},
		},
	},
})
