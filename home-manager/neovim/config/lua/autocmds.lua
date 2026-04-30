vim.filetype.add({
  pattern = {
    [".*/.github/workflows/.*%.yml"]  = "yaml.ghaction",
    [".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
    [".*/.envrc"]                     = "zsh",
    [".*/Dockerfile.*"]               = "Dockerfile",
    [".*/templates/.*%.tpl"]          = "helm",
    [".*/templates/.*%.ya?ml"]        = "helm",
    ["helmfile.*%.ya?ml"]             = "helm",
    [".*%.go%.tmpl"]                  = "gotmpl",
  },
  extension = {
    template = "templ",
    gotmpl   = "gotmpl",
  },
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
