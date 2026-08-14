require("lz.n").load({
  {
    "blink.cmp",
    event = "InsertEnter",
    after = function()
      require("blink.cmp").setup({
        keymap = { preset = "enter" },

        appearance = { nerd_font_variant = "mono" },

        completion = {
          accept = { auto_brackets = { enabled = true } },
          menu = {
            border = "single",
            draw = {
              treesitter = { "lsp" },
              components = {
                -- mini.icons covers both the file icons (Path source) and the
                -- LSP kind symbols, so neither nvim-web-devicons nor lspkind
                -- is needed here.
                kind_icon = {
                  text = function(ctx)
                    local category = ctx.source_name == "Path" and "file" or "lsp"
                    local key = ctx.source_name == "Path" and ctx.label or ctx.kind
                    local icon = require("mini.icons").get(category, key)
                    return (icon or ctx.kind_icon) .. ctx.icon_gap
                  end,
                  highlight = function(ctx)
                    local category = ctx.source_name == "Path" and "file" or "lsp"
                    local key = ctx.source_name == "Path" and ctx.label or ctx.kind
                    local _, hl = require("mini.icons").get(category, key)
                    return hl or ctx.kind_hl
                  end,
                },
                kind = {
                  highlight = function(ctx)
                    local _, hl = require("mini.icons").get("lsp", ctx.kind)
                    return hl or ctx.kind_hl
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
            window = { border = "single" },
          },
        },

        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },

        signature = {
          enabled = true,
          window = { border = "single" },
        },

        fuzzy = {
          -- nixpkgs ships target/release/libblink_cmp_fuzzy.dylib with the
          -- plugin, so the Rust matcher is always there. Demanding it means a
          -- packaging regression fails loudly instead of quietly dropping back
          -- to the much slower Lua matcher.
          implementation = "rust",
          sorts = { "exact", "score", "sort_text" },
        },
      })
    end,
  },
})
