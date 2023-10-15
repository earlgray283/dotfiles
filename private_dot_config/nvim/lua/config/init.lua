require("config.options")

vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<D-S-Up>", "<Cmd>vertical resize +2<cr>")
vim.api.nvim_create_autocmd("ModeChanged", {
	callback = function()
		vim.cmd([[checktime]])

		require("nvim-tree.api").tree.reload()
	end,
})
