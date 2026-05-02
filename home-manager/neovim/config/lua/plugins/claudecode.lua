require("lz.n").load({
  {
    "claudecode.nvim",
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend",
      "ClaudeCodeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeSelectModel",
      "ClaudeCodeTreeAdd",
    },
    keys = {
      { "<leader>cc",  "<Cmd>ClaudeCode<CR>",            desc = "Toggle Claude" },
      { "<leader>cf",  "<Cmd>ClaudeCodeFocus<CR>",        desc = "Focus Claude" },
      { "<leader>cr",  "<Cmd>ClaudeCode --resume<CR>",    desc = "Resume Claude" },
      { "<leader>cC",  "<Cmd>ClaudeCode --continue<CR>",  desc = "Continue Claude" },
      { "<leader>cm",  "<Cmd>ClaudeCodeSelectModel<CR>",  desc = "Select model" },
      { "<leader>cb",  "<Cmd>ClaudeCodeAdd %<CR>",        desc = "Add current buffer" },
      { "<leader>cs",  "<Cmd>ClaudeCodeSend<CR>",         mode = "v", desc = "Send selection" },
      { "<leader>cs",  "<Cmd>ClaudeCodeTreeAdd<CR>",      ft = "NvimTree", desc = "Add file" },
      { "<leader>cA",  "<Cmd>ClaudeCodeDiffAccept<CR>",   desc = "Accept diff" },
      { "<leader>cd",  "<Cmd>ClaudeCodeDiffDeny<CR>",     desc = "Deny diff" },
    },
    after = function()
      require("claudecode").setup({
        terminal = {
          provider = "native",
        },
      })
    end,
  },
})
