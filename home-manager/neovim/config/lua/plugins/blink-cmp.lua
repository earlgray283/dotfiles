require("lz.n").load({
	{
		"blink.cmp",
		event = "InsertEnter",
		after = function()
			require("blink.cmp").setup({
				keymap = { preset = "enter" },

				appearance = { nerd_font_variant = "mono" },

				completion = {
					accept = { auto_brackets = { enabled = true } },
					menu = {
						border = "single",
						draw = {
							treesitter = { "lsp" },
							components = {
								kind_icon = {
									text = function(ctx)
										local icon = ctx.kind_icon
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
											if dev_icon then
												icon = dev_icon
											end
										else
											icon = require("lspkind").symbol_map[ctx.kind] or ""
										end
										return icon .. ctx.icon_gap
									end,
									highlight = function(ctx)
										local hl = ctx.kind_hl
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local _, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
											if dev_hl then
												hl = dev_hl
											end
										end
										return hl
									end,
								},
								kind = {
									highlight = function(ctx)
										local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
										return hl
									end,
								},
							},
						},
					},
					documentation = {
						auto_show = true,
						window = { border = "single" },
					},
				},

				sources = {
					default = { "lsp", "omni", "path", "snippets", "buffer" },
				},

				signature = {
					enabled = true,
					window = { border = "single" },
				},

				fuzzy = {
					implementation = "prefer_rust_with_warning",
					sorts = { "exact", "score", "sort_text" },
				},
			})
		end,
	},
})
