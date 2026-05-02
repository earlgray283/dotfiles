local map = vim.keymap.set

-- General
map("n", "<Esc>",   "<Cmd>nohlsearch<CR>", { silent = true })
map("n", "<Space>", "<NOP>",               { noremap = true, silent = true })

-- LSP (set globally; effective only when an LSP client is attached)
map("n", "gD",        vim.lsp.buf.declaration,                                       { silent = true, desc = "Go to declaration" })
map("n", "gd",        vim.lsp.buf.definition,                                        { silent = true, desc = "Go to definition" })
map("n", "K",         vim.lsp.buf.hover,                                             { silent = true, desc = "Hover" })
map("n", "V",         function() vim.diagnostic.open_float({ anchor = "NE" }) end,   { silent = true, desc = "Open diagnostic float" })
map("n", "gi",        vim.lsp.buf.implementation,                                    { silent = true, desc = "Go to implementation" })
map("n", "<C-k>",     vim.lsp.buf.signature_help,                                    { silent = true, desc = "Signature help" })
map("n", "gt",        vim.lsp.buf.type_definition,                                   { silent = true, desc = "Go to type definition" })
map("n", "gr",        vim.lsp.buf.references,                                        { silent = true, desc = "References" })
map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action,                             { silent = true, desc = "Code action" })

-- Window resize
map("n", "<C-Up>",   "<Cmd>resize +2<CR>", { desc = "Resize window up" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Resize window down" })
