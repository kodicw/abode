{ pkgs, noctalia-pkg, ... }:

pkgs.writeShellScriptBin "noctalia-shell" ''
  exec ${noctalia-pkg}/bin/noctalia "$@"
''
