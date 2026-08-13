require("lz.n").load({
  {
    "conform.nvim",
    event = "BufWritePre",
    after = function()
      require("conform").setup({
        formatters_by_ft = {
          cue            = { "cue_fmt" },
          dockerfile     = { "dockerfmt" },
          go             = { "goimports" },
          javascript     = { "biome", "prettier", stop_after_first = true },
          just           = { "just" },
          json           = { "biome" },
          lua            = { "stylua" },
          markdown       = { "dprint" },
          nix            = { "nixfmt" },
          proto          = { "buf", "clang-format", stop_after_first = true },
          rust           = { "rustfmt" },
          sql            = { "sqlfluff" },
          terraform      = { "terraform_fmt" },
          toml           = { "taplo" },
          typescript     = { "biome", "prettier", stop_after_first = true },
          typescriptreact = { "biome", "prettier", stop_after_first = true },
          yaml           = { "yamlfmt" },
        },
      })

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      -- Format asynchronously so the UI never blocks on save. BufWritePre lets the
      -- original (unformatted) write go through immediately; once the async job
      -- finishes we re-write the buffer (noautocmd, to avoid retriggering this
      -- same autocmd) so the file on disk ends up formatted a moment later.
      -- Caveat: quitting immediately after `:wq` can race the async job.
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern  = "*",
        callback = function(args)
          if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then return end
          require("conform").format({
            bufnr       = args.buf,
            timeout_ms  = 2000,
            lsp_format  = "fallback",
            async       = true,
          }, function(err, did_edit)
            if not err and did_edit and vim.api.nvim_buf_is_valid(args.buf) then
              vim.api.nvim_buf_call(args.buf, function()
                vim.cmd("silent! noautocmd write")
              end)
            end
          end)
        end,
      })

      vim.api.nvim_create_user_command("ConformDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { bang = true, desc = "Disable autoformat-on-save" })

      vim.api.nvim_create_user_command("ConformEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable autoformat-on-save" })
    end,
  },
})
