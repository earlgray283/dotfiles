{ pkgs, lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.nvf.settings.vim = {
    autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      setupOpts = {
        keymap.preset = "enter";

        appearance.nerd_font_variant = "mono";

        completion = {
          accept.auto_brackets.enabled = true;
          menu = {
            border = "single";
            draw = {
              treesitter = [ "lsp" ];
              components = {
                kind_icon = {
                  text = mkLuaInline ''
                    function(ctx)
                      local icon = ctx.kind_icon
                      if vim.tbl_contains({ "Path" }, ctx.source_name) then
                          local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                          if dev_icon then
                              icon = dev_icon
                          end
                      else
                          icon = require("lspkind").symbol_map[ctx.kind] or ""
                      end
                      return icon .. ctx.icon_gap
                    end
                  '';
                  highlight = mkLuaInline ''
                    function(ctx)
                      local hl = ctx.kind_hl
                      if vim.tbl_contains({ "Path" }, ctx.source_name) then
                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                        if dev_icon then
                          hl = dev_hl
                        end
                      end
                      return hl
                    end
                  '';
                };
                kind = {
                  highlight = mkLuaInline ''
                    function(ctx)
                      local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                      return hl
                    end
                  '';
                };
              };
            };
          };
          documentation = {
            auto_show = true;
            window.border = "single";
          };
        };
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        signature = {
          enabled = true;
          window.border = "single";
        };
        fuzzy = {
          implementation = "prefer_rust_with_warning";
          sorts = [
            "exact"
            "score"
            "sort_text"
          ];
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      # nvim-autopairs: 自動括弧閉じ
      nvim-autopairs = {
        package = nvim-autopairs;
        setup = "require('nvim-autopairs').setup({})";
      };

      # lazydev: Lua 開発支援 (lua ファイルのみ)
      lazydev-nvim = {
        package = lazydev-nvim;
        setup = ''
          require('lazydev').setup({
            library = {
              { path = "''${3rd}/luv/library", words = { "vim%.uv" } },
            },
          })
        '';
      };

      # mini.comment: コメント
      mini-comment = {
        package = mini-comment;
        setup = "require('mini.comment').setup({})";
      };
    };
  };
}
