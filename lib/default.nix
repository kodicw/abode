{
  self,
  nixpkgs,
  home-manager,
  polarbear,
  llm-agents,
  ...
}:

{
  mkHome =
    {
      system,
      username,
      modules ? [ ],
    }:
    let
      userModule = import "${self}/config/users/${username}.nix";
      isMinimal = userModule.minimal or false;

      baseModules =
        if isMinimal then
          [
            self.homeManagerModules.config-home
            (
              { pkgs, ... }:
              {
                home.packages = [
                  pkgs.python3
                  llm-agents.packages.${system}.antigravity-cli
                  llm-agents.packages.${system}.herdr
                ];
                programs.antigravity.enable = true;
              }
            )
          ]
        else
          [
            self.homeManagerModules.default
          ];
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit system polarbear llm-agents userModule;
      };
      modules = baseModules ++ modules;
    };
}
