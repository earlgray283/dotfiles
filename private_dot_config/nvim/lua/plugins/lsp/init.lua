local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufEnter", "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		init = function()
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})
			require("plugins.lsp.util").on_attach(function(client, buffer)
				require("plugins.lsp.keymap")
			end)
			local lspconfig = require("lspconfig")
			local capabilities =
				require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

			lspconfig.gopls.setup({
				cmd = { "gopls", "serve" },
				filetypes = { "go", "gomod" },
				root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
						},
					},
				},
				capabilities = capabilities,
			})
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = {
								"vim",
								"require",
							},
						},
					},
				},
				capabilities = capabilities,
			})
			lspconfig.rust_analyzer.setup({
				on_attach = function(client)
					require("completion").on_attach(client)
				end,
				settings = {
					["rust-analyzer"] = {
						imports = {
							granularity = { group = "module" },
							prefix = "self",
						},
						diagnostics = { enable = true },
						cargo = {
							buildScripts = { enable = true },
						},
						procMacro = {
							enable = true,
						},
						check = {
							command = "clippy",
						},
					},
				},
				capabilities = capabilities,
			})
			lspconfig.dockerls.setup({ capabilities = capabilities })
			lspconfig.docker_compose_language_service.setup({ capabilities = capabilities })
			lspconfig.zls.setup({ capabilities = capabilities })
			lspconfig.clangd.setup({ capabilities = capabilities })
			lspconfig.eslint.setup({ capabilities = capabilities })
			lspconfig.tsserver.setup({ capabilities = capabilities })
			lspconfig.html.setup({ capabilities = capabilities })
			lspconfig.jsonls.setup({ capabilities = capabilities })
			lspconfig.yamlls.setup({ capabilities = capabilities })
			lspconfig.bufls.setup({ capabilities = capabilities })
		end,
	},
	{
		"nvimdev/guard.nvim",
		event = { "BufEnter", "BufReadPre", "BufNewFile" },
		dependencies = { "mason.nvim" },
		opts = function()
			local ft = require("guard.filetype")
			ft("go"):fmt({ cmd = "goimports" }):lint({ cmd = "staticcheck" })
			ft("rust"):fmt("lsp"):lint({
				cmd = "cargo",
				args = { "clippy" },
			})
			ft("lua"):fmt("stylua"):lint("luacheck")
			ft("yaml"):fmt({ cmd = "yamlfmt" }):lint({ cmd = "yamllint" })
			ft("yaml"):fmt({ cmd = "yamlfmt" }):lint({ cmd = "actionlint" })
			ft("typescript,javascript,typescriptreact,json,markdown,toml,dockerfile"):fmt({ cmd = "dprint" })
			ft("c,cpp"):fmt("clang-format")
			ft("dockerfile"):lint("hadolint")
			ft("typescript,javascript,typescriptreact"):lint({ cmd = "eslint" })
			ft("proto"):fmt("clang-format"):lint({ cmd = "buf" })
			require("guard").setup({
				fmt_on_save = true,
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		version = false,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"onsails/lspkind.nvim",
		},
		init = function()
			local cmp = require("cmp")
			cmp.setup({
				completion = {
					completeopt = "menu,menuone,noselect,noinsert",
				},
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
				formatting = {
					format = require("lspkind").cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
						before = function(_, vim_item)
							return vim_item
						end,
					}),
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
					{ name = "nvim_lsp_signature_help" },
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
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},
}
