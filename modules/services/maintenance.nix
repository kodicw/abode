{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.maintenance;
in
{
  options.services.maintenance = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable scheduled maintenance of Home Manager and Nix store.";
    };

    interval = mkOption {
      type = types.str;
      default = "weekly";
      description = "How often to run the maintenance (systemd calendar event format).";
    };

    deleteOlderThan = mkOption {
      type = types.str;
      default = "30d";
      description = "Delete generations and Nix store paths older than this duration.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.hm-maintenance = {
      Unit = {
        Description = "Home Manager and Nix Maintenance Service";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "hm-maintenance-run" ''
          set -euo pipefail
          export PATH="${config.home.homeDirectory}/.nix-profile/bin:${pkgs.nix}/bin:/usr/bin:/bin"

          echo "=== Starting Home Manager & Nix Maintenance ==="

          # Delete old Home Manager generations
          if command -v home-manager >/dev/null 2>&1; then
            echo "Expiring Home Manager generations older than ${cfg.deleteOlderThan}..."
            DAYS=$(echo "${cfg.deleteOlderThan}" | ${pkgs.gnused}/bin/sed -E 's/([0-9]+)d/-\1 days/')
            home-manager expire-generations "$DAYS"
          else
            echo "home-manager command not found, skipping generation expiry."
          fi

          # Run Nix store garbage collection
          echo "Running Nix store garbage collection..."
          nix-collect-garbage --delete-older-than ${cfg.deleteOlderThan}

          # Optimize Nix store
          echo "Optimizing Nix store..."
          nix-store --optimise

          echo "=== Maintenance Complete ==="
        ''}";
      };
    };

    systemd.user.timers.hm-maintenance = {
      Unit = {
        Description = "Timer for Home Manager and Nix Maintenance Service";
      };
      Timer = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
