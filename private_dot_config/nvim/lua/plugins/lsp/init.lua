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
			local langs = {
				gopls = {
					cmd = { "gopls", "serve" },
					filetypes = { "go", "gomod" },
					root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
						},
					},
				},
				lua_ls = {
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
				},
				rust_analyzer = {
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
				},
				clangd = { filetypes = { "c", "cpp", "h" } },
				tsserver = {},
				angularls = {},
				dockerls = {},
				docker_compose_language_service = {
					root_dir = require("lspconfig/util").root_pattern("docker-compose.yaml", "compose.yaml"),
				},
				bufls = {},
				html = {},
				jsonls = {},
				yamlls = {
					settings = {
						yaml = {
							schemas = {
								["https://github.com/OAI/OpenAPI-Specification/raw/main/schemas/v3.1/schema.yaml"] = "/*",
							},
						},
					},
				},
				tailwindcss = {},
			}

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/diagnostic"] =
				vim.lsp.with(vim.lsp.diagnostic.on_diagnostic, { update_in_insert = true })
			local capabilities =
				require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
			for name, config in pairs(langs) do
				config.capabilities = capabilities
				require("lspconfig")[name].setup(config)
			end

			require("plugins.lsp.util").on_attach(function(client, buffer)
				require("plugins.lsp.keymap")
			end)
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
					fields = { "kind", "abbr", "menu" },
					format = require("lspkind").cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
						before = function(entry, vim_item)
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
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},
	{
		"nvimdev/guard.nvim",
		dependencies = {
			"mason.nvim",
			"nvimdev/guard-collection",
		},
		init = function()
			local ft = require("guard.filetype")
			ft("go"):fmt({ cmd = "goimports", fname = true })
			ft("rust"):fmt("lsp"):lint({
				cmd = "cargo",
				args = { "clippy" },
			})
			ft("lua"):fmt("stylua"):lint("luacheck")
			ft("yaml"):fmt({ cmd = "yamlfmt" }):lint({ cmd = "yamllint" })
			ft("yaml"):fmt({ cmd = "yamlfmt" }):lint({ cmd = "actionlint" })
			ft("typescript,javascript,typescriptreact,json,markdown,toml,dockerfile"):fmt("dprint")
			ft("c,cpp"):fmt("clang-format")
			ft("dockerfile"):lint("hadolint")
			ft("typescript,javascript,typescriptreact"):lint({ cmd = "eslint" })
			ft("proto"):fmt({
				cmd = "buf",
				args = { "format", "-w" },
				fname = true,
			}):lint({
				cmd = "buf",
				args = { "lint" },
			})
			require("guard").setup({
				fmt_on_save = true,
				lsp_as_default_formatter = false,
			})
		end,
	},
}
