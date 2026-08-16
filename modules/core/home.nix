{
  config,
  pkgs,
  lib,
  userModule,
  ...
}:

let
  isAarch64 = pkgs.stdenv.hostPlatform.system == "aarch64-linux";
in
{
  home.username = userModule.username;
  home.homeDirectory = userModule.homeDirectory;
  home.stateVersion = userModule.stateVersion;

  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 28800;
    maxCacheTtl = 86400;
    pinentry.package = if isAarch64 then pkgs.pinentry-tty else pkgs.pinentry-curses;
    extraConfig = lib.mkIf isAarch64 ''
      no-grab
      no-allow-external-cache
      allow-loopback-pinentry
    '';
  };

  # Crostini-only: ensure gpg-agent can find nix binaries
  systemd.user.services.gpg-agent.Service.Environment = lib.mkIf isAarch64 [
    "PATH=%h/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
  ];
}

