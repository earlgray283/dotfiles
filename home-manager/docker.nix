{ config, lib, ... }:

{
  home.file =
    lib.genAttrs [ ".docker/cli-plugins/docker-compose" ".docker/cli-plugins/docker-buildx" ]
      (path: {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/mise/shims/${baseNameOf path}";
      });
}
