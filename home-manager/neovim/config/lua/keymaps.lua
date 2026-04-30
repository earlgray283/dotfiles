local map = vim.keymap.set

-- General
map("n", "<Esc>",   "<Cmd>nohlsearch<CR>", { silent = true })
map("n", "<Space>", "<NOP>",               { noremap = true, silent = true })

-- LSP (set globally; effective only when an LSP client is attached)
map("n", "gD",        vim.lsp.buf.declaration,   { silent = true })
map("n", "gd",        vim.lsp.buf.definition,     { silent = true })
map("n", "K",         vim.lsp.buf.hover,          { silent = true })
map("n", "V",         function() vim.diagnostic.open_float({ anchor = "NE" }) end,  { silent = true })
map("n", "gi",        vim.lsp.buf.implementation, { silent = true })
map("n", "<C-k>",     vim.lsp.buf.signature_help, { silent = true })
map("n", "gt",        vim.lsp.buf.type_definition, { silent = true })
map("n", "gr",        vim.lsp.buf.references,     { silent = true })
map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, { silent = true })

-- Window resize
map("n", "<C-Up>",   "<Cmd>resize +2<CR>")
map("n", "<C-Down>", "<Cmd>resize -2<CR>")
