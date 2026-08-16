{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.session-keepalive;
in
{
  options.services.session-keepalive = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable background user session keep-alive for Linux VM on Android / Crostini.";
    };

    enableLinger = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable systemd logind user lingering via activation script.";
    };

    enableSshKeepAlive = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to configure SSH client keep-alive options to prevent connection drop.";
    };
  };

  config = mkIf cfg.enable {
    # Activation script to enable user linger on systemd logind
    home.activation.enableLinger = mkIf cfg.enableLinger (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD loginctl enable-linger "${config.home.username}" 2>/dev/null || true
      ''
    );

    # Systemd user service to keep the user systemd daemon active
    systemd.user.services.session-keepalive = {
      Unit = {
        Description = "Linux VM User Session Keep-Alive Daemon";
        Documentation = [ "https://github.com/kodicw/abode" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
        Restart = "always";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Systemd user service for persistent Tmux server
    systemd.user.services.tmux-server = {
      Unit = {
        Description = "Tmux Persistent Terminal Session Server";
        After = [ "network.target" ];
      };
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.tmux}/bin/tmux new-session -s main -d";
        ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # SSH Keep-Alive settings
    programs.ssh = mkIf cfg.enableSshKeepAlive {
      enable = true;
      settings = {
        "*" = {
          ServerAliveInterval = 30;
          ServerAliveCountMax = 10;
        };
      };
    };
  };
}
