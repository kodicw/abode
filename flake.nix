{
  description = "abode - Home Manager configuration";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polarbear.url = "github:kodicw/polarbear";
    llm-agents.url = "github:numtide/llm-agents.nix";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
    };
    noctalia-plugins = {
      url = "github:noctalia-dev/noctalia-plugins";
      flake = false;
    };
    # ── Skill sources ──
    agent-skills-nix.url = "github:Kyure-A/agent-skills-nix";
    vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
    addyosmani-skills = {
      url = "github:addyosmani/agent-skills";
      flake = false;
    };
    ailabs-skills = {
      url = "github:ailabs-393/ai-labs-claude-skills";
      flake = false;
    };
    bigboss-skills = {
      url = "github:0xbigboss/claude-code";
      flake = false;
    };
    affaan-skills = {
      url = "github:affaan-m/everything-claude-code";
      flake = false;
    };
    mindrally-skills = {
      url = "github:mindrally/skills";
      flake = false;
    };
    unclecatvn-skills = {
      url = "github:unclecatvn/agent-skills";
      flake = false;
    };
    xixu-skills = {
      url = "github:xixu-me/skills";
      flake = false;
    };
    google-skills = {
      url = "github:google/skills";
      flake = false;
    };
  };

  outputs =
    inputs@{
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
          inputs
          ;
      };
    in
    {
      lib = mylib;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        import ./pkgs { inherit pkgs inputs; }
      );

      homeManagerModules = {
        activation-crostini-icons = ./modules/activation/crostini-icons.nix;
        config-home = ./modules/core/home.nix;
        packages = ./modules/core/packages.nix;
        skills-agent-skills = ./modules/core/agent-skills.nix;
        programs-csharp = ./modules/programs/csharp.nix;
        programs-devtools = ./modules/programs/devtools.nix;
        programs-shells = ./modules/programs/shells.nix;
        programs-terminals = ./modules/programs/terminals.nix;
        programs-ai = ./modules/programs/ai.nix;
        session = ./modules/core/session.nix;
        systemd-opencode-server = ./modules/services/opencode-server.nix;
        systemd-rclone-gdrive = ./modules/services/rclone-gdrive.nix;
        systemd-maintenance = ./modules/services/maintenance.nix;

        desktop-niri = ./modules/desktop/niri.nix;
        desktop-shell = ./modules/desktop/shell.nix;
        desktop =
          { ... }:
          {
            imports = [
              self.homeManagerModules.desktop-niri
              self.homeManagerModules.desktop-shell
            ];
          };
        skills-nix-nixos-guide = ./modules/skills/nix-nixos-guide;
        skills-justfile-guide = ./modules/skills/justfile-guide;
        skills-xonsh-guide = ./modules/skills/xonsh-guide;
        skills-pi-coding-agent = ./modules/skills/pi-coding-agent;
        skills-gh-cli = ./modules/skills/gh-cli;
        skills-contributing-guide = ./modules/skills/contributing-guide;
        skills-opentofu-guide = ./modules/skills/opentofu-guide;
        skills-home-manager-guide = ./modules/skills/home-manager-guide;

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
              self.homeManagerModules.systemd-maintenance
              self.homeManagerModules.skills-nix-nixos-guide
              self.homeManagerModules.skills-justfile-guide
              self.homeManagerModules.skills-xonsh-guide
              self.homeManagerModules.skills-pi-coding-agent
              self.homeManagerModules.skills-gh-cli
              self.homeManagerModules.skills-contributing-guide
              self.homeManagerModules.skills-opentofu-guide
              self.homeManagerModules.skills-home-manager-guide
              self.homeManagerModules.skills-agent-skills
            ];
          };
      };

      homeConfigurations = {
        kodicw = mylib.mkHome {
          system = "x86_64-linux";
          username = "kodicw";
          modules = [
            self.homeManagerModules.default
            self.homeManagerModules.desktop
            self.homeManagerModules.activation-crostini-icons
          ];
        };
        charles = mylib.mkHome {
          system = "x86_64-linux";
          username = "charles";
          modules = [
            self.homeManagerModules.default
            self.homeManagerModules.desktop
            self.homeManagerModules.activation-crostini-icons
          ];
        };
        nixos = mylib.mkHome {
          system = "x86_64-linux";
          username = "nixos";
          modules = [
            self.homeManagerModules.default
          ];
        };
        kodiwalls = mylib.mkHome {
          system = "x86_64-linux";
          username = "kodiwalls";
          modules = [
            self.homeManagerModules.default
            self.homeManagerModules.desktop
            self.homeManagerModules.activation-crostini-icons
          ];
        };
        droid = mylib.mkHome {
          system = "aarch64-linux";
          username = "droid";
          modules = [
            self.homeManagerModules.default
            self.homeManagerModules.desktop
            self.homeManagerModules.activation-crostini-icons
          ];
        };
        charlyndavi = mylib.mkHome {
          system = "x86_64-linux";
          username = "charlyndavi";
          modules = [
            self.homeManagerModules.config-home
            self.homeManagerModules.activation-crostini-icons
            self.homeManagerModules.programs-ai
          ];
        };
      };

      checks = forAllSystems (
        system:
        lib.mapAttrs' (name: value: lib.nameValuePair name value.activationPackage) (
          lib.filterAttrs (_: value: value.pkgs.stdenv.hostPlatform.system == system) self.homeConfigurations
        )
      );
    };
}
