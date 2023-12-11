return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        go = { "golangcilint" },
        dockerfile = { "hadolint" },
        typescript = { "eslint" },
      },
      linters = {
        golangcilint = {
          args = {
            "run",
            "--out-format",
            "json",
            function()
              return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
            end,
            -- "-E",
            -- "exhaustruct",
          },
        },
      },
    },
  },
}
