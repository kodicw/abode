{ pkgs, ... }:

{
  systemd.user.services.opencode-server = {
    Unit = {
      Description = "opencode: Headless opencode server";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.opencode}/bin/opencode serve --port 8080 --hostname 127.0.0.1";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}