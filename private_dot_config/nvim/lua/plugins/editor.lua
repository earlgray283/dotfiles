return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    keys = {
      { "<leader>th", "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "Open Terminal(horizontal)" },
      { "<leader>tv", "<Cmd>ToggleTerm direction=vertical<CR>", desc = "Open Terminal(vertical)" },
      { "<leader>tf", "<Cmd>ToggleTerm direction=float<CR>", desc = "Open Terminal(float)" },
    },
  },
}
