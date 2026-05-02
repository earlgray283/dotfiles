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
      nvim-web-devicons
      lspkind-nvim
      friendly-snippets
      SchemaStore-nvim
      mini-nvim
      (nvim-treesitter.withPlugins (p: with p; [
        bash c diff go gotmpl hcl html
        javascript jsdoc json lua luadoc luap
        markdown markdown_inline nix
        python query regex rust
        toml tsx typescript vim vimdoc xml yaml
      ]))
      nvim-treesitter-context
      nvim-treesitter-textobjects
      # Lazy loaded (opt) -- lz.n controls when to packadd these
      { plugin = nvim-ts-autotag;             optional = true; }
      { plugin = lualine-nvim;                optional = true; }
      { plugin = telescope-nvim;                  optional = true; }
      { plugin = telescope-fzf-native-nvim;       optional = true; }
      { plugin = telescope-file-browser-nvim;     optional = true; }
      { plugin = gitsigns-nvim;               optional = true; }
      { plugin = toggleterm-nvim;             optional = true; }
      { plugin = vim-illuminate;              optional = true; }
      { plugin = nvim-spectre;                optional = true; }
      { plugin = openingh-nvim;               optional = true; }
      { plugin = blink-cmp;                   optional = true; }
      { plugin = nvim-autopairs;              optional = true; }
      { plugin = lazydev-nvim;                optional = true; }
      { plugin = conform-nvim;                optional = true; }
      { plugin = nvim-lint;                   optional = true; }
      { plugin = nvim-tree-lua;               optional = true; }
      { plugin = nvim-lspconfig;              optional = true; }
      { plugin = rustaceanvim;                optional = true; }
    ];
  };

  xdg.configFile."nvim".source = ./config;
}
