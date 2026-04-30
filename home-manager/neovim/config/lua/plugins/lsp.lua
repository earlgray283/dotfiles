require("lz.n").load({
  {
    "nvim-lspconfig",
    event = "BufRead",
    after = function()
      -- Load lspconfig to register default server configs (cmd, filetypes, root_markers)
      require("lspconfig")

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border     = "single",
        max_height = 20,
      })

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
        "gopls",
        "ts_ls",
        "lua_ls",
        "cssls",
        "terraformls",
        "taplo",
        "html",
        "marksman",
        "nixd",
        "yamlls",
      })
    end,
  },
  {
    "rustaceanvim",
    ft = "rust",
  },
})
