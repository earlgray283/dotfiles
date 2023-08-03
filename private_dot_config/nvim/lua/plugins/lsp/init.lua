local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufEnter", "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		init = function()
			local Util = require("plugins.lsp.util")
			Util.on_attach(function(client, buffer)
				require("plugins.lsp.keymap")
			end)
			local lspconfig = require("lspconfig")
			local util = require("lspconfig/util")
			lspconfig.gopls.setup({
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
			lspconfig.lua_ls.setup({})
		end,
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufEnter", "BufReadPre", "BufNewFile" },
		dependencies = { "mason.nvim", "nvim-lua/plenary.nvim" },
		opts = function()
			local null_ls = require("null-ls")
			return {
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
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
					null_ls.builtins.diagnostics.buf, -- proto
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
			}
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"petertriho/cmp-git",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-cmdline",
		},
		init = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
			})

			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "git" },
				}, {
					{ name = "buffer" },
				}),
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
}
