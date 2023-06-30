-- Set up lsp manager
require("mason").setup({
	ui = {
		border = "single",
	},
})
require("mason-lspconfig").setup({})

local border = "single"
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or border
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Set up language servers
local util = require("lspconfig/util")
require("lspconfig").lua_ls.setup({})
require("lspconfig").rust_analyzer.setup({
	on_attach = function(client)
		require("completion").on_attach(client)
	end,
	settings = {
		["rust-analyzer"] = {
			imports = {
				granularity = {
					group = "module",
				},
				prefix = "self",
			},
			cargo = {
				buildScripts = {
					enable = true,
				},
			},
			procMacro = {
				enable = true,
			},
		},
	},
})
require("lspconfig").gopls.setup({
	cmd = { "gopls", "serve" },
	filetypes = { "go", "gomod" },
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
})
require("lspconfig").yamlls.setup({})
require("lspconfig").clangd.setup({})
