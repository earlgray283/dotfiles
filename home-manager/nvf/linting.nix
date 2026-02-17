{
  inputs,
  ...
}:
let
  inherit (inputs.nvf.lib.nvim.dag) entryAfter;
in
{
  programs.nvf.settings.vim = {
    diagnostics.nvim-lint = {
      enable = true;
      linters_by_ft = {
        dockerfile = [ "hadolint" ];
        go = [ "golangcilint" ];
        markdown = [ "vale" ];
        nix = [ "nix" ];
        proto = [ "protolint" "buf_lint" ];
        rust = [ "clippy" ];
        sql = [ "sqlruff" ];
        typescript = [ "oxlint" ];
        typescriptreact = [ "oxlint" ];
        javascript = [ "oxlint" ];
      };
    };

    # yaml.ghaction は動的に追加 (filetype が特殊なため)
    luaConfigRC.nvim-lint-ghaction = entryAfter [ "pluginConfigs" ] ''
      require("lint").linters_by_ft["yaml.ghaction"] = { "actionlint" }
    '';
  };
}
