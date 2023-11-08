return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type lspconfig.options
      ---@diagnostic disable-next-line: missing-fields
      servers = {
        angularls = {},

        bufls = {},

        clangd = {},

        cssls = {},

        dockerls = {},

        docker_compose_language_service = {
          root_dir = require("lspconfig/util").root_pattern("docker-compose.yaml", "compose.yaml"),
        },

        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        },

        html = {},

        jsonls = {},

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

        marksman = {},

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

        tailwindcss = {},

        tsserver = {},

        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://github.com/OAI/OpenAPI-Specification/raw/main/schemas/v3.1/schema.yaml"] = "/*",
              },
            },
          },
        },
      },
    },
  },
}
