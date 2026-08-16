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
      profilePath = "${self}/profiles/${username}.nix";
      baseProfile = if builtins.pathExists profilePath then import profilePath else { };
      userModule = {
        username = baseProfile.username or username;
        homeDirectory = baseProfile.homeDirectory or "/home/${username}";
        stateVersion = baseProfile.stateVersion or "25.11";
      }
      // baseProfile;
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit
          system
          polarbear
          llm-agents
          userModule
          inputs
          ;
      };
      inherit modules;
    };
}
