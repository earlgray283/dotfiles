-- format current buffer when save
-- https://github.com/neovim/nvim-lspconfig/issues/1792#issuecomment-1352782205
vim.api.nvim_create_autocmd("BufWritePre", {
	buffer = buffer,
	callback = function()
		vim.lsp.buf.format({
			async = false
		})
	end
})

-- run goimports when save
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = '*.go',
	callback = function()
		vim.lsp.buf.code_action({
			context = {
				only = {
					'source.organizeImports'
				}
			},
			apply = true
		})
	end
})

-- launch nvim-tree when open nvim
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("nvim-tree.api").tree.open()
	end
})

-- close nvim-tree automatically when close all buffers
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#beauwilliams
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
	pattern = "NvimTree_*",
	callback = function()
		local layout = vim.api.nvim_call_function("winlayout", {})
		if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then
			vim.cmd("confirm quit")
		end
	end
})

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.lsp.buf.hover({})
	end
})
