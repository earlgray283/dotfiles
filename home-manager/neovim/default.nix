{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [
      # Always loaded (start)
      lz-n
      catppuccin-nvim
      friendly-snippets
      SchemaStore-nvim
      # Supplies icons (replacing nvim-web-devicons and lspkind) and the
      # statusline (replacing lualine), on top of comment/pairs/cursorword.
      # oil, fzf-lua and which-key all prefer mini.icons when it is set up.
      mini-nvim
      oil-nvim
      (nvim-treesitter.withPlugins (
        p: with p; [
          bash
          c
          diff
          go
          gotmpl
          hcl
          html
          javascript
          jsdoc
          json
          lua
          luadoc
          luap
          markdown
          markdown_inline
          nix
          python
          query
          regex
          rust
          toml
          tsx
          typescript
          vim
          vimdoc
          xml
          yaml
        ]
      ))
      # Lazy loaded (opt) -- lz.n controls when to packadd these
      {
        # treesitter.lua declares this with `event = "BufRead"`, which only has
        # an effect once the plugin is opt.
        plugin = nvim-treesitter-context;
        optional = true;
      }
      {
        plugin = nvim-ts-autotag;
        optional = true;
      }
      {
        plugin = fzf-lua;
        optional = true;
      }
      {
        plugin = which-key-nvim;
        optional = true;
      }
      {
        plugin = gitsigns-nvim;
        optional = true;
      }
      {
        plugin = toggleterm-nvim;
        optional = true;
      }
      {
        plugin = grug-far-nvim;
        optional = true;
      }
      {
        plugin = openingh-nvim;
        optional = true;
      }
      {
        plugin = blink-cmp;
        optional = true;
      }
      {
        plugin = lazydev-nvim;
        optional = true;
      }
      {
        plugin = conform-nvim;
        optional = true;
      }
      {
        plugin = nvim-lint;
        optional = true;
      }
      {
        plugin = nvim-lspconfig;
        optional = true;
      }
      {
        plugin = rustaceanvim;
        optional = true;
      }
    ];
  };

  xdg.configFile."nvim".source = ./config;
}
