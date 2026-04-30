require("lz.n").load({
  {
    "telescope.nvim",
    cmd = { "Telescope" },
    keys = {
      { "<leader>ff", "<Cmd>Telescope find_files<CR>",  desc = "Find files" },
      { "<leader>/",  "<Cmd>Telescope live_grep<CR>",   desc = "Live grep" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>",     desc = "Buffers" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>",   desc = "Help tags" },
      { "<leader>fd", "<Cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fs", "<Cmd>Telescope git_status<CR>",  desc = "Git status" },
      {
        "<leader>ft",
        function() require("telescope").extensions.file_browser.file_browser() end,
        desc = "File browser",
      },
    },
    after = function()
      vim.cmd.packadd("telescope-fzf-native.nvim")
      vim.cmd.packadd("telescope-file-browser.nvim")
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          preview = { treesitter = false },
        },
        pickers = {
          git_status = { preview = { treesitter = false } },
        },
        extensions = {
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
          },
          file_browser = {},
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
    end,
  },
})
