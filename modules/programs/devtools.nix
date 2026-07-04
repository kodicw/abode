{ pkgs, ... }:

{
  programs.git = {
    enable = false;
    settings = {
      user = {
        name = "Kodi Walls";
        email = "kodicw@gmail.com";
      };
    };
  };

  programs.gh.enable = true;



  programs.fastfetch = {
    enable = true;
    settings = {
      modules = [
        "title"
        "separator"
        "os"
        "shell"
        "uptime"
        "memory"
        "break"
        "colors"
      ];
    };
  };

  fonts.fontconfig.enable = true;
}