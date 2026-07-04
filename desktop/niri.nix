{ config, pkgs, inputs, ... }:

let
  system = pkgs.system;
in
{
  home.packages = [
    inputs.self.packages.${system}.niri-desktop
  ];

  xdg.configFile."niri/config.kdl".text = ''
    // Niri configuration managed via Home Manager (abode)
    // For manual and keys see: https://github.com/YaLTeR/niri/wiki/Configuration

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            dwt
        }
    }

    output "eDP-1" {
        mode "1920x1080@60"
        scale 1.0
    }

    layout {
        gaps 16
        center-focused-column "never"
        default-column-width { proportion 0.5; }
    }

    // Example keybindings:
    binds {
        // Modkey is Super (Command/Windows key)
        "Mod+Return" { spawn "ghostty"; }
        "Mod+Q" { close-window; }
        "Mod+Left" { focus-column-left; }
        "Mod+Right" { focus-column-right; }
        "Mod+Up" { focus-window-up; }
        "Mod+Down" { focus-window-down; }
    }
  '';
}
