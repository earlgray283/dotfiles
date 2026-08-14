vim.filetype.add({
  pattern = {
    [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
    [".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
    [".*/.envrc"] = "zsh",
    [".*/Dockerfile.*"] = "Dockerfile",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
    [".*%.go%.tmpl"] = "gotmpl",
  },
  extension = {
    template = "templ",
    gotmpl = "gotmpl",
  },
})

-- Everything that walks the whole buffer gets switched off past 1MB. The flag
-- is read by treesitter.lua, nvim-lint.lua and conform.lua (disable_autoformat).
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1024 * 1024 then
      vim.b[args.buf].bigfile = true
      vim.b[args.buf].minicursorword_disable = true
      vim.b[args.buf].disable_autoformat = true
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      vim.opt_local.syntax = "off"
      vim.opt_local.swapfile = false
    end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg and arg ~= "" then
      local stat = vim.uv.fs_stat(arg)
      if stat and stat.type == "directory" then
        vim.cmd.cd(arg)
      elseif stat and stat.type == "file" then
        vim.cmd.cd(vim.fn.fnamemodify(arg, ":h"))
      end
    end
  end,
})
