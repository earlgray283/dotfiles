return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 100000,
  },
  {
    "LazyVim/LazyVim",
    dependencies = {
      "gbprod/nord.nvim",
    },
    opts = {
      colorscheme = "nord",
    },
  },
}
