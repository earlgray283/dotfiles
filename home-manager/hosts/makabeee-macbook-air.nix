{ lib, ... }:

{
  home.activation.checkHostname = lib.hm.dag.entryBefore [ "checkFilesChanged" ] ''
    expected="earlgray@makabeee-macbook-air"
    actual="$(whoami)@$(hostname -s)"
    if [ "$actual" != "$expected" ]; then
      echo "Error: this configuration is for $expected, but current host is $actual" >&2
      exit 1
    fi
  '';
}
