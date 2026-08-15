{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  isDesktop = system == "x86_64-linux";
  # Google Chrome is only supported on x86_64-linux
  chrome = if isDesktop then pkgs.google-chrome else null;
in
{
  home.packages = [
    inputs.self.packages.${system}.niri-desktop
  ]
  ++ pkgs.lib.optionals isDesktop [
    (pkgs.runCommand "google-chrome-icons" { } ''
      mkdir -p $out/share
      cp -r ${chrome}/share/icons $out/share/
    '')
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

    animations {
        off
    }

    layout {
        gaps 16
        center-focused-column "never"
        default-column-width { proportion 0.5; }
        background-color "transparent"
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
        ${lib.optionalString isDesktop ''
        // Noctalia controls
        "Alt+Space" { spawn "noctalia-shell" "msg" "launcher" "toggle"; }
        "Mod+C" { spawn "noctalia-shell" "msg" "panel-toggle" "control-center"; }
        "Mod+V" { spawn "noctalia-shell" "msg" "panel-toggle" "clipboard"; }
        "Mod+Escape" { spawn "noctalia-shell" "msg" "panel-toggle" "session"; }
        ''}
    }

    ${lib.optionalString isDesktop ''
    // Allow Noctalia's backdrop/wallpaper layer to show in overview mode
    layer-rule {
        match namespace="^noctalia-backdrop$"
        place-within-backdrop true
    }
    ''}

    spawn-at-startup "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE"
    ${lib.optionalString isDesktop ''spawn-at-startup "noctalia-shell"''}
  '';

  xdg.enable = true;

  xdg.desktopEntries = pkgs.lib.optionalAttrs (system == "x86_64-linux") {
    google-chrome = {
      name = "Google Chrome";
      genericName = "Web Browser";
      exec = "google-chrome-stable %U";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/x-mimearchive"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      icon = "google-chrome";
    };
  };
}
