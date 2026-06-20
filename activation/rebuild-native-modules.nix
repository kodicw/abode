{ config, pkgs, ... }:

let
  nodejs = pkgs.nodejs_latest;
  rebuildScript = pkgs.writeShellScript "rebuild-better-sqlite3" ''
    set -e
    PI_MODULES_DIR="$HOME/.pi/agent/npm/node_modules"
    BETTER_SQLITE3_DIR="$PI_MODULES_DIR/better-sqlite3"

    if [ ! -d "$BETTER_SQLITE3_DIR" ]; then
      exit 0
    fi

    NODE_VERSION=$(${nodejs}/bin/node --version 2>/dev/null || echo "unknown")
    STAMP_FILE="$BETTER_SQLITE3_DIR/.node-version-stamp"

    CURRENT_STAMP=""
    if [ -f "$STAMP_FILE" ]; then
      CURRENT_STAMP=$(cat "$STAMP_FILE")
    fi

    if [ "$NODE_VERSION" = "$CURRENT_STAMP" ]; then
      exit 0
    fi

    echo "Rebuilding better-sqlite3 for Node.js $NODE_VERSION..."
    cd "$BETTER_SQLITE3_DIR"
    export PATH="${pkgs.python3}/bin:${pkgs.gnumake}/bin:${pkgs.gcc}/bin:${nodejs}/bin:$PATH"
    
    if npm run build-release; then
      echo "$NODE_VERSION" > "$STAMP_FILE"
      echo "better-sqlite3 rebuilt successfully."
    else
      echo "Warning: better-sqlite3 rebuild failed."
      echo "Run manually: cd $BETTER_SQLITE3_DIR && npm run build-release"
    fi
  '';
in
{
  home.activation = {
    rebuildNativeModules = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ${rebuildScript}
    '';
  };
}
