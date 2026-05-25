{
  description = "abode - Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polarbear.url = "github:kodicw/polarbear";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      polarbear,
      llm-agents,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = lib.intersectLists lib.systems.flakeExposed (lib.attrNames nixpkgs.legacyPackages);

      forAllSystems = lib.genAttrs systems;

      mkHome =
        system: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit polarbear llm-agents;
            userModule = import ./config/users/${username}.nix;
          };
          modules = [
            self.homeManagerModules.default
          ];
        };
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      homeManagerModules = {
        activation-crostini-icons = ./activation/crostini-icons.nix;
        config-home = ./config/home.nix;
        packages = ./packages.nix;
        programs-csharp = ./programs/csharp.nix;
        programs-devtools = ./programs/devtools.nix;
        programs-shells = ./programs/shells.nix;
        programs-terminals = ./programs/terminals.nix;
        programs-ai = ./programs/ai.nix;
        session = ./session.nix;
        systemd-opencode-server = ./systemd/opencode-server.nix;

        skills-nix-nixos-guide = ./skills/nix-nixos-guide;
        skills-justfile-guide = ./skills/justfile-guide;
        skills-xonsh-guide = ./skills/xonsh-guide;
        skills-pi-coding-agent = ./skills/pi-coding-agent;
        skills-gh-cli = ./skills/gh-cli;
        skills-contributing-guide = ./skills/contributing-guide;
        skills-opentofu-guide = ./skills/opentofu-guide;
        skills-home-manager-guide = ./skills/home-manager-guide;

        # Combined default module for convenience
        default =
          { ... }:
          {
            imports = [
              self.homeManagerModules.activation-crostini-icons
              self.homeManagerModules.config-home
              self.homeManagerModules.packages
              self.homeManagerModules.programs-devtools
              self.homeManagerModules.programs-shells
              self.homeManagerModules.programs-terminals
              self.homeManagerModules.programs-ai
              self.homeManagerModules.session
              self.homeManagerModules.skills-nix-nixos-guide
              self.homeManagerModules.skills-justfile-guide
              self.homeManagerModules.skills-xonsh-guide
              self.homeManagerModules.skills-pi-coding-agent
              self.homeManagerModules.skills-gh-cli
              self.homeManagerModules.skills-contributing-guide
              self.homeManagerModules.skills-opentofu-guide
              self.homeManagerModules.skills-home-manager-guide
            ];
          };
      };

      homeConfigurations = {
        kodicw = mkHome "x86_64-linux" "kodicw";
        charles = mkHome "x86_64-linux" "charles";
        nixos = mkHome "x86_64-linux" "nixos";
        kodiwalls = mkHome "x86_64-linux" "kodiwalls";
        droid = mkHome "aarch64-linux" "droid";
      };

      checks = forAllSystems (
        system:
        lib.mapAttrs' (
          name: value:
          lib.nameValuePair name value.activationPackage
        ) (lib.filterAttrs (_: value: value.pkgs.system == system) self.homeConfigurations)
      );
    };
}
