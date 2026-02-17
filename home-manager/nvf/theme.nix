{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    theme = {
      enable = true;
      name = "catppuccin";
      style = "frappe";
    };

    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        bash
        c
        diff
        go
        gotmpl
        html
        javascript
        jsdoc
        json
        lua
        luadoc
        luap
        markdown
        markdown_inline
        python
        query
        regex
        toml
        tsx
        typescript
        vim
        vimdoc
        xml
        yaml
      ];

      context = {
        enable = true;
      };

      textobjects = {
        enable = true;
      };
    };
  };
}
