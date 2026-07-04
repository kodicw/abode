{ pkgs, lib, ... }:

let
  isAarch64 = pkgs.system == "aarch64-linux";
in
{
  programs.ghostty = {
    enable = !isAarch64;
    settings = {
      background = "#000000";
      background-opacity = 0.85;
      window-decoration = false;
      gtk-titlebar = false;
      font-family = "JetBrainsMono Nerd Font";
      font-size = 10;
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;
      theme = "catppuccin-mocha";
      show_startup_tips = false;
      default_layout = "compact";
      keybinds = {
        normal = {
          "bind \"Alt t\"" = { NewTab = { }; };
        };
      };
    };
  };

  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        pane
        pane size=1 borderless=true {
            plugin location="zellij:status-bar"
        }
    }
  '';
}