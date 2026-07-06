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

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
    };
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };
}