{ pkgs, lib, ... }:

let
  isAarch64 = pkgs.stdenv.hostPlatform.system == "aarch64-linux";
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
          "bind \"Alt t\"" = {
            NewTab = { };
          };
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    historyLimit = 50000;
    keyMode = "vi";
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
    extraConfig = ''
      set -g status-style bg=default
      set -g detach-on-destroy off
    '';
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
