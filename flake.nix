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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
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
    openspec-skills = {
      url = "github:full-stack-skills/openspec-skills";
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
      flake-parts,
      treefmt-nix,
      home-manager,
      polarbear,
      llm-agents,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        treefmt-nix.flakeModule
      ];

      systems = import inputs.systems;

      perSystem =
        { pkgs, system, ... }:
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.shfmt.enable = true;
          };

          packages = import ./pkgs {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            inherit inputs;
          };
        };

      flake =
        let
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
            systemd-session-keepalive = ./modules/services/session-keepalive.nix;

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
            desktop-full =
              { ... }:
              {
                imports = [
                  self.homeManagerModules.default
                  self.homeManagerModules.desktop
                  self.homeManagerModules.activation-crostini-icons
                ];
              };

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
                  self.homeManagerModules.systemd-session-keepalive
                  self.homeManagerModules.skills-agent-skills
                ];
              };
          };

          homeConfigurations = {
            kodicw = mylib.mkHome {
              system = "x86_64-linux";
              username = "kodicw";
              modules = [ self.homeManagerModules.desktop-full ];
            };
            charles = mylib.mkHome {
              system = "x86_64-linux";
              username = "charles";
              modules = [ self.homeManagerModules.desktop-full ];
            };
            nixos = mylib.mkHome {
              system = "x86_64-linux";
              username = "nixos";
              modules = [ self.homeManagerModules.default ];
            };
            kodiwalls = mylib.mkHome {
              system = "x86_64-linux";
              username = "kodiwalls";
              modules = [ self.homeManagerModules.desktop-full ];
            };
            droid = mylib.mkHome {
              system = "aarch64-linux";
              username = "droid";
              modules = [ self.homeManagerModules.desktop-full ];
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
        };
    };
}
