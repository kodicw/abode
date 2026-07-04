{
  self,
  nixpkgs,
  home-manager,
  polarbear,
  llm-agents,
  inputs,
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
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit system polarbear llm-agents userModule inputs;
      };
      inherit modules;
    };
}
