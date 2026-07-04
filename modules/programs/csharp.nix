{ pkgs, ... }:

{
  home.packages = [
    pkgs.dotnet-sdk_8
    pkgs.omnisharp-roslyn
    pkgs.netcoredbg # Debugger for C#
  ];

  # Optional: Set environment variables for dotnet
  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_8}";
  };
}
