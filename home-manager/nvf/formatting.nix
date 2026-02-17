{
  lib,
  inputs,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;
  inherit (inputs.nvf.lib.nvim.dag) entryAfter;
in
{
  programs.nvf.settings.vim = {
    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        # format_on_save は luaConfigRC で手動管理 (disable_autoformat フラグ対応のため)
        format_on_save = null;
        formatters_by_ft = {
          cue = [ "cue_fmt" ];
          dockerfile = [ "dockerfmt" ];
          go = [ "goimports" ];
          javascript = mkLuaInline ''{ "biome", "prettier", stop_after_first = true }'';
          just = [ "just" ];
          json = [ "biome" ];
          lua = [ "stylua" ];
          markdown = [ "dprint" ];
          nix = [ "nixfmt" ];
          proto = mkLuaInline ''{ "buf", "clang-format", stop_after_first = true }'';
          rust = [ "rustfmt" ];
          sql = [ "sqlfluff" ];
          terraform = [ "terraform_fmt" ];
          toml = [ "taplo" ];
          typescript = mkLuaInline ''{ "biome", "prettier", stop_after_first = true }'';
          typescriptreact = mkLuaInline ''{ "biome", "prettier", stop_after_first = true }'';
          yaml = [ "yamlfmt" ];
        };
      };
    };

    luaConfigRC.conform-autoformat = entryAfter [ "pluginConfigs" ] ''
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then return end
          require("conform").format({ bufnr = args.buf, timeout_ms = 2000, lsp_format = "never" })
        end,
      })
      vim.api.nvim_create_user_command("ConformDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable autoformat-on-save" })
      vim.api.nvim_create_user_command("ConformEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable autoformat-on-save" })
    '';
  };
}
