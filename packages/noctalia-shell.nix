{ pkgs, ... }:

let
  noctalia = pkgs.noctalia or (pkgs.writeShellScriptBin "noctalia" ''
    echo "Noctalia placeholder. Install it via system configuration or flake inputs."
  '');
in
pkgs.writeShellScriptBin "noctalia-shell" ''
  exec ${noctalia}/bin/noctalia "$@"
''
