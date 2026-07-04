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

      mylib = import ./lib {
        inherit
          self
          nixpkgs
          home-manager
          polarbear
          llm-agents
          ;
      };
    in
    {
      lib = mylib;
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
        kodicw = mylib.mkHome {
          system = "x86_64-linux";
          username = "kodicw";
          modules = [ self.homeManagerModules.activation-crostini-icons ];
        };
        charles = mylib.mkHome {
          system = "x86_64-linux";
          username = "charles";
        };
        nixos = mylib.mkHome {
          system = "x86_64-linux";
          username = "nixos";
        };
        kodiwalls = mylib.mkHome {
          system = "x86_64-linux";
          username = "kodiwalls";
          modules = [ self.homeManagerModules.activation-crostini-icons ];
        };
        droid = mylib.mkHome {
          system = "aarch64-linux";
          username = "droid";
          modules = [ self.homeManagerModules.activation-crostini-icons ];
        };
        charlyndavi = mylib.mkHome {
          system = "x86_64-linux";
          username = "charlyndavi";
          modules = [ self.homeManagerModules.activation-crostini-icons ];
        };
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
