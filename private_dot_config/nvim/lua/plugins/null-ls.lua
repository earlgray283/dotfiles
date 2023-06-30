local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
	sources = {
		null_ls.builtins.code_actions.gitsigns,
		null_ls.builtins.code_actions.eslint,
		null_ls.builtins.diagnostics.actionlint, -- github actions
		null_ls.builtins.formatting.yamlfmt, -- yaml
		null_ls.builtins.formatting.goimports, -- go
		null_ls.builtins.formatting.rustfmt, -- rust
		null_ls.builtins.formatting.stylua, -- lua
		null_ls.builtins.formatting.dprint, -- js/ts, json, markdown, etc.
		null_ls.builtins.formatting.clang_format, -- c/c++, proto
		null_ls.builtins.formatting.zigfmt, -- zig
		null_ls.builtins.diagnostics.staticcheck, -- go
		null_ls.builtins.diagnostics.hadolint, -- Dockerfile
		null_ls.builtins.diagnostics.eslint, -- js/ts
		null_ls.builtins.diagnostics.buf,   -- proto
		null_ls.builtins.completion.luasnip,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
			})
		end
	end,
})
