{ config, pkgs, userModule, ... }:

{
  home.username = userModule.username;
  home.homeDirectory = userModule.homeDirectory;
  home.stateVersion = userModule.stateVersion;

  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;
}
