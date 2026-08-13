-- mini.files is a submodule of mini-nvim, which is already a start plugin;
-- set up directly, same as mini.comment.
local MiniFiles = require("mini.files")

MiniFiles.setup({
  windows = {
    preview       = true,
    width_focus   = 30,
    width_preview = 50,
  },
})

local function toggle()
  if not MiniFiles.close() then
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
  end
end

vim.keymap.set("n", "<leader>e", toggle, { desc = "Toggle file explorer" })
