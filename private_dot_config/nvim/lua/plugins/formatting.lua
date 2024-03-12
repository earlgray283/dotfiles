local util = require("conform.util")

return {
  {
    "stevearc/conform.nvim",
    opts = {
      ---@type table<string, conform.FormatterUnit[]>
      formatters_by_ft = {
        css = { { "prettier", "lsp" } },
        fish = { "fish_indent" },
        go = { "goimports", "gofumpt" },
        html = { "prettier" },
        javascript = { { "prettier", "dprint" } },
        json = { { "prettier", "dprint" } },
        lua = { "stylua" },
        proto = { "buf" },
        python = { "ruff_format" },
        rust = { "lsp" },
        scss = { { "prettier", "lsp" } },
        sh = { "shfmt" },
        typescript = { { "prettier", "dprint" } },
        typescriptreact = { { "prettier", "dprint" } },
        yaml = { "yamlfmt" },
      },
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        dprint = {
          command = util.from_node_modules("dprint"),
        },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
    },
  },
}
