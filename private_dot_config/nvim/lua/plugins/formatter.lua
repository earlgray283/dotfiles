return {
	{
		"nvimdev/guard.nvim",
		dependencies = {
			"mason.nvim",
			"nvimdev/guard-collection",
		},
		init = function()
			local ft = require("guard.filetype")
			ft("go"):fmt({ cmd = "goimports", fname = true })
			ft("rust"):fmt("lsp")
			ft("lua"):fmt("stylua")
			ft("yaml"):fmt({ cmd = "yamlfmt" })
			ft("yaml"):fmt({ cmd = "yamlfmt" })
			ft("markdown,toml,dockerfile"):fmt("dprint")
			ft("typescript,javascript,typescriptreact,json"):fmt("dprint"):append("prettier")
			ft("c,cpp"):fmt("clang-format")
			ft("dockerfile")
			ft("proto"):fmt({
				cmd = "buf",
				args = { "format", "-w" },
				fname = true,
			})
			require("guard").setup({
				fmt_on_save = true,
				lsp_as_default_formatter = false,
			})
		end,
	},
}
