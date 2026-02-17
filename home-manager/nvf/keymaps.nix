{ ... }:
{
  programs.nvf.settings.vim.keymaps = [
    # General
    { key = "<Esc>"; mode = "n"; action = "<Cmd>nohlsearch<CR>"; silent = true; }
    { key = "<Space>"; mode = "n"; action = "<NOP>"; noremap = true; silent = true; }

    # LSP
    { key = "gD"; mode = "n"; lua = true; action = "vim.lsp.buf.declaration"; silent = true; }
    { key = "gd"; mode = "n"; lua = true; action = "vim.lsp.buf.definition"; silent = true; }
    { key = "K"; mode = "n"; lua = true; action = "vim.lsp.buf.hover"; silent = true; }
    { key = "V"; mode = "n"; lua = true; action = "vim.diagnostic.open_float"; silent = true; }
    { key = "gi"; mode = "n"; lua = true; action = "vim.lsp.buf.implementation"; silent = true; }
    { key = "<C-k>"; mode = "n"; lua = true; action = "vim.lsp.buf.signature_help"; silent = true; }
    { key = "gt"; mode = "n"; lua = true; action = "vim.lsp.buf.type_definition"; silent = true; }
    { key = "gr"; mode = "n"; lua = true; action = "vim.lsp.buf.references"; silent = true; }
    { key = "<space>ca"; mode = [ "n" "v" ]; lua = true; action = "vim.lsp.buf.code_action"; silent = true; }

    # Toggleterm
    { key = "<leader>th"; mode = "n"; action = "<Cmd>ToggleTerm direction=horizontal<CR>"; desc = "Toggle horizontal terminal"; }
    { key = "<leader>t1"; mode = "n"; action = "<Cmd>1ToggleTerm direction=horizontal<CR>"; desc = "Toggle terminal 1"; }
    { key = "<leader>t2"; mode = "n"; action = "<Cmd>2ToggleTerm direction=horizontal<CR>"; desc = "Toggle terminal 2"; }
    { key = "<leader>t3"; mode = "n"; action = "<Cmd>3ToggleTerm direction=horizontal<CR>"; desc = "Toggle terminal 3"; }
    { key = "<C-Up>"; mode = "n"; action = "<Cmd>resize +2<CR>"; }
    { key = "<C-Down>"; mode = "n"; action = "<Cmd>resize -2<CR>"; }

    # Telescope extensions
    { key = "<leader>ft"; mode = "n"; lua = true; action = ''function() require("telescope").extensions.file_browser.file_browser() end''; desc = "File browser"; }

    # Spectre
    { key = "<leader>S"; mode = "n"; lua = true; action = ''function() require("spectre").toggle() end''; desc = "Toggle Spectre"; }
    { key = "<leader>sw"; mode = "n"; lua = true; action = ''function() require("spectre").open_visual({select_word=true}) end''; desc = "Search current word"; }
    { key = "<leader>sw"; mode = "v"; lua = true; action = ''function() require("spectre").open_visual() end''; desc = "Search current word"; }
    { key = "<leader>sp"; mode = "n"; lua = true; action = ''function() require("spectre").open_file_search({select_word=true}) end''; desc = "Search on current file"; }
  ];
}
