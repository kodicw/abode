{ pkgs, inputs }:

{
  niri-desktop = pkgs.callPackage ./applications/niri-desktop { };
} // pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
  noctalia-shell = pkgs.callPackage ./applications/noctalia-shell {
    noctalia-pkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
