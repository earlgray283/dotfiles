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
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
    },
  },
}
