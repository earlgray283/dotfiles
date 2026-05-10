require("lz.n").load({
	{
		"nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			-- Load lspconfig to register default server configs (cmd, filetypes, root_markers)
			require("lspconfig")

			vim.lsp.config("nixd", {
				settings = {
					nixd = {
						options = {
							["home-manager"] = {
								expr = '(builtins.getFlake (builtins.toString ./.)).homeConfigurations."earlgray".options',
							},
						},
					},
				},
			})

			vim.lsp.config("yamlls", {
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			})

			vim.lsp.enable({
				"biome",
				"cssls",
				"gopls",
				"html",
				"lua_ls",
				"marksman",
				"nixd",
				"taplo",
				"terraformls",
				"ts_ls",
				"yamlls",
			})
		end,
	},
	{
		"rustaceanvim",
		ft = "rust",
	},
})
