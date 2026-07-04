{ config, ... }:

{
  home.activation = {
    syncCrostiniIcons = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ~/.local/share/applications ~/.local/share/icons

      if [ -d ~/.nix-profile/share/icons ]; then
        for i in ~/.nix-profile/share/icons/*; do
          ln -sfn "$i" ~/.local/share/icons/$(basename "$i")
        done
      fi

      if [ -d ~/.nix-profile/share/applications ]; then
        for f in ~/.nix-profile/share/applications/*.desktop; do
          dest="$HOME/.local/share/applications/$(basename "$f")"
          if [ ! -e "$dest" ] || [ -L "$dest" ] || grep -q "nixGLIntel" "$dest"; then
            ln -sfn "$f" "$dest"
          fi
        done
      fi
    '';
  };
}