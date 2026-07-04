{ config, pkgs, inputs, ... }:

let
  system = pkgs.system;
in
{
  home.packages = [
    inputs.self.packages.${system}.noctalia-shell
  ];

  xdg.configFile."noctalia/config.json".text = ''
    {
      "theme": "dark",
      "panels": [
        {
          "position": "top",
          "widgets": ["workspaces", "clock", "battery", "network"]
        }
      ]
    }
  '';
}
