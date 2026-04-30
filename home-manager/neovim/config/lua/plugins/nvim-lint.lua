require("lz.n").load({
  {
    "nvim-lint",
    event = "BufRead",
    after = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        dockerfile      = { "hadolint" },
        go              = { "golangcilint" },
        markdown        = { "vale" },
        nix             = { "nix" },
        proto           = { "protolint", "buf_lint" },
        rust            = { "clippy" },
        sql             = { "sqlruff" },
        typescript      = { "oxlint" },
        typescriptreact = { "oxlint" },
        javascript      = { "oxlint" },
        ["yaml.ghaction"] = { "actionlint" },
      }

      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
})
