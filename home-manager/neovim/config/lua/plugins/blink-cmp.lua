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
            auto_show_delay_ms = 50,
            window = { border = "single" },
          },
        },

        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },

        signature = {
          enabled = true,
          trigger = { show_on_insert = true },
          window = { border = "single" },
        },

        fuzzy = {
          -- nixpkgs ships the dylib; fail loudly rather than fall back to the Lua matcher.
          implementation = "rust",
          sorts = { "exact", "score", "sort_text" },
        },
      })
    end,
  },
})
