{ pkgs, ... }:

{
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "rclone: Remote FUSE filesystem for Google Drive";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "/usr/bin/mkdir -p %h/gdrive";
      ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: %h/gdrive --vfs-cache-mode full --vfs-cache-max-size 10G --vfs-read-chunk-size 128M --dir-cache-time 72h --buffer-size 128M --poll-interval 15s --allow-other --allow-non-empty";
      ExecStop = "/usr/bin/fusermount -u %h/gdrive";
      Restart = "on-failure";
      RestartSec = "10s";
      RestartPreventExitStatus = "1";
    };
  };
}