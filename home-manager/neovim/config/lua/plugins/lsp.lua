require("lz.n").load({
  {
    "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      -- nvim-lspconfig ships each server as lsp/<name>.lua, which
      -- vim.lsp.enable() resolves straight off the runtimepath. Requiring the
      -- lspconfig module would load the old framework for nothing.
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
