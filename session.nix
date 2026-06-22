{ pkgs, userModule, ... }:

let
  isAarch64 = pkgs.system == "aarch64-linux";
in
{
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINFO_DIRS = "/usr/share/terminfo:/lib/terminfo:${userModule.homeDirectory}/.nix-profile/share/terminfo";
  } // (if isAarch64 then {} else {
    XKB_DEFAULT_LAYOUT = "us";
    XKB_DEFAULT_MODEL = "pc105";
    XKB_DEFAULT_RULES = "evdev";
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/share/X11/xkb";
    DISPLAY = ":0";
    WAYLAND_DISPLAY = "wayland-0";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    XMODIFIERS = "@im=none";
  });
}