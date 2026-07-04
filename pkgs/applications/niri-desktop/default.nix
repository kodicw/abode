{ pkgs, ... }:

let
  niri = pkgs.niri;
  system = pkgs.stdenv.hostPlatform.system;
  # Google Chrome is only officially packaged for x86_64-linux in nixpkgs
  chrome = if system == "x86_64-linux" then pkgs.google-chrome else null;
in
pkgs.writeShellScriptBin "niri-desktop" ''
  # Expose Google Chrome only within the Niri session path if supported on this architecture
  ${if chrome != null then "export PATH=\"${chrome}/bin:$PATH\"" else ""}

  # Ensure graphical session variables are set
  export XDG_CURRENT_DESKTOP=niri
  export XDG_SESSION_DESKTOP=niri
  export XDG_SESSION_TYPE=wayland

  # Wrap in dbus-run-session if no active session bus is found
  if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    exec dbus-run-session -- ${niri}/bin/niri "$@"
  else
    exec ${niri}/bin/niri "$@"
  fi
''
