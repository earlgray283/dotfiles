local map = vim.keymap.set

-- General
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { silent = true })
map("n", "<Space>", "<NOP>", { noremap = true, silent = true })

map("n", "V", function()
  vim.diagnostic.open_float({ anchor = "NE" })
end, { silent = true, desc = "Open diagnostic float" })

-- Window resize
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Resize window up" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Resize window down" })

-- Keep vim.lsp.buf.* out of file scope: naming it there loads the LSP stack at startup.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local function opts(desc)
      return { buffer = args.buf, silent = true, desc = desc }
    end

    map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
    map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
    map("n", "K", vim.lsp.buf.hover, opts("Hover"))
    map("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
    map("n", "<C-k>", vim.lsp.buf.signature_help, opts("Signature help"))
    map("n", "gt", vim.lsp.buf.type_definition, opts("Go to type definition"))
    map("n", "gr", vim.lsp.buf.references, opts("References"))
    map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts("Code action"))
  end,
})
