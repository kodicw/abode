{ pkgs, inputs }:

{
  niri-desktop = pkgs.callPackage ./applications/niri-desktop { };
  noctalia-shell = pkgs.callPackage ./applications/noctalia-shell {
    noctalia-pkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
