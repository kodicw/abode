{ pkgs, ... }:

let
  niri = pkgs.niri;
in
pkgs.writeShellScriptBin "niri-desktop" ''
  # Ensure graphical session variables are set
  export XDG_CURRENT_DESKTOP=niri
  export XDG_SESSION_DESKTOP=niri
  export XDG_SESSION_TYPE=wayland
  
  exec ${niri}/bin/niri "$@"
''
