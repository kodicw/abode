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
  noctalia-pkg = inputs.noctalia.packages.${system}.default;
in
{
  home.packages = lib.optionals isDesktop [
    inputs.self.packages.${system}.noctalia-shell
  ];

  xdg.dataFile."noctalia/plugins/wallhaven" = lib.mkIf isDesktop {
    source = "${inputs.noctalia-plugins}/wallhaven";
  };

  xdg.configFile."noctalia/config.toml" = lib.mkIf isDesktop {
    text = ''
      # Noctalia configuration managed via Home Manager (abode)
      # For settings reference see: https://docs.noctalia.dev

      [backdrop]
      enabled = true

      [bar.main]
      position = "left"
      margin_ends = 0
      start = [ "control-center", "workspaces", "wallhaven_2" ]
      center = [ "cat", "cpu", "ram" ]
      end = [ "launcher", "session" ]

      [session]
      logout = "niri msg action quit --skip-confirmation"

      [control_center]
      hidden_tabs = [ "monitor", "power", "network", "bluetooth" ]

      [[control_center.shortcuts]]
      type = "caffeine"

      [[control_center.shortcuts]]
      type = "notification"

      [desktop_widgets]
      schema_version = 2
      widget_order = []

      [desktop_widgets.grid]
      cell_size = 16
      major_interval = 4
      visible = true

      [desktop_widgets.widget]

      [dock]
      auto_hide = true
      icon_size = 37
      launcher_position = "start"
      main_axis_padding = 0

      [location]
      auto_locate = true

      [lockscreen_widgets]
      enabled = false
      schema_version = 2
      widget_order = [ "lockscreen-login-box@winit" ]

      [lockscreen_widgets.grid]
      cell_size = 16
      major_interval = 4
      visible = true

      [lockscreen_widgets.widget."lockscreen-login-box@winit"]
      box_height = 70.0
      box_width = 400.0
      cx = 800.0
      cy = 881.0
      output = "winit"
      rotation = 0.0
      type = "login_box"

      [lockscreen_widgets.widget."lockscreen-login-box@winit".settings]
      background_color = "surface_variant"
      background_opacity = 0.88
      background_radius = 12.0
      input_opacity = 1.0
      input_radius = 6.0
      show_caps_lock = true
      show_keyboard_layout = true
      show_login_button = true
      show_password_hint = true

      [plugin_settings."noctalia/wallhaven"]
      download_dir = ""

      [plugins]
      enabled = [ "noctalia/wallhaven", "noctalia/bongocat" ]

      [shell]
      niri_overview_type_to_launch_enabled = true

      [shell.animation]
      enabled = false

      [shell.panel]
      transparency_mode = "transparent"

      [theme]
      mode = "dark"
      builtin = "Ayu"
      community_palette = "Tokyo Night Moon"
      wallpaper_scheme = "soft"

      [theme.templates]
      builtin_ids = [ "kitty" ]

      [widget.cat]
      type = "noctalia/bongocat:cat"

      [widget.control-center]
      custom_image = "${noctalia-pkg}/share/noctalia/assets/images/distros/nixos.svg"
      glyph = "nixos"

      [widget.cpu]
      capsule = true
      capsule_radius = "auto"
      glyph = "cpu-usage"
      show_label = false

      [widget.ram]
      show_label = false

      [widget.wallhaven]
      type = "noctalia/wallhaven:wallhaven"

      [widget.wallhaven_2]
      type = "noctalia/wallhaven:wallhaven"
    '';
  };
}