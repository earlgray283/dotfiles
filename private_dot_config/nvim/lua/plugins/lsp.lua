return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        angularls = {},

        cssls = {},

        docker_compose_language_service = {
          root_dir = require("lspconfig/util").root_pattern("docker-compose.yaml", "compose.yaml"),
        },

        html = {},

        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          -- Use this to add any additional keymaps
          -- for specific lsp servers
          ---@type LazyKeysSpec[]
          -- keys = {},
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      },
      diagnostics = {},
    },
  },
}
