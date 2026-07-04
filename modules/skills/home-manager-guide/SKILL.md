---
name: home-manager-guide
description: Comprehensive guide for Home Manager — the Nix-powered user environment manager. Covers standalone and NixOS module setups, flake configurations, program modules, custom modules, dotfile management, secrets, state versioning, and troubleshooting. Use when configuring, debugging, or extending Home Manager setups.
---

# Home Manager Guide

Home Manager manages your user environment (dotfiles, packages, services) using the Nix expression language. It can run standalone on any Linux/macOS system with Nix, or as a NixOS module for system-wide integration.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `home-manager switch` | Apply configuration |
| `home-manager build` | Build but do not activate |
| `home-manager generations` | List past generations |
| `home-manager switch --generation N` | Rollback to generation N |
| `home-manager edit` | Open `home.nix` in `$EDITOR` |
| `home-manager news` | Show release notes |
| `home-manager option <name>` | Inspect option docs |
| `home-manager switch --flake .#user` | Flake-based activation |

## Installation

### Standalone (any system with Nix)

```bash
# Using nix-channel (classic)
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Using flakes (recommended)
nix run home-manager/master -- init --switch
# Or manually add to your flake (see Flake Setup below)

> **Note:** Flake support is experimental and may have backwards-incompatible changes, but it is the de facto standard for modern Home Manager setups. Home Manager is developed against the `nixos-unstable` branch, so stable NixOS users should ensure their nixpkgs input is compatible.
```

### As a NixOS Module

```nix
# flake.nix
{
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alice = import ./home.nix;
          }
        ];
      };
    };
}
```

## Flake Setup (Standalone)

This is the most common modern setup.

```nix
{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.alice = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
```

### Multi-User Flake

```nix
{
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      mkHome = username: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit username; };
        };
    in {
      homeConfigurations = {
        "alice@desktop" = mkHome "alice" "x86_64-linux";
        "alice@laptop"  = mkHome "alice" "x86_64-linux";
        "bob@server"    = mkHome "bob"   "aarch64-linux";
      };
    };
}
```

### Activation

```bash
# From the flake directory
home-manager switch --flake .#alice
home-manager switch --flake .#alice@desktop

# Without installing home-manager to PATH
nix run home-manager -- switch --flake .#alice
```

## Configuration Structure

### Minimal `home.nix`

```nix
{ config, pkgs, ... }:

{
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git
    vim
    htop
  ];

  programs.bash.enable = true;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
```

### Key Options

| Option | Purpose | Example |
|--------|---------|---------|
| `home.username` | Your username | `"alice"` |
| `home.homeDirectory` | Absolute home path | `"/home/alice"` |
| `home.stateVersion` | Compatibility version | `"25.05"` |
| `home.packages` | Packages to install | `[ pkgs.git pkgs.vim ]` |
| `home.file` | Dotfiles and config files | See Dotfiles section |
| `home.sessionVariables` | Env vars | `{ EDITOR = "vim"; }` |
| `home.sessionPath` | Additional PATH entries | `[ "$HOME/.local/bin" ]` |
| `home.shellAliases` | Shell aliases (generic) | `{ ll = "ls -la"; }` |

### `stateVersion` Rules

- Set once and **never change it**
- It controls migration behavior for breaking changes
- Use the version from when you first set up Home Manager
- New setups: use the current stable release (e.g., `"25.05"` or `"26.05"`)

## Program Modules

Home Manager has built-in modules for 200+ programs. Prefer these over manual `home.file` when available.

### Shells

```nix
programs.bash = {
  enable = true;
  shellAliases = { ll = "ls -la"; };
  initExtra = ''
    export PATH="$HOME/.local/bin:$PATH"
  '';
};

programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
    plugins = [ "git" "docker" ];
  };
};

programs.fish = {
  enable = true;
  shellAliases = { ll = "ls -la"; };
};
```

### Editors

```nix
programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  plugins = with pkgs.vimPlugins; [ vim-nix ];
  extraConfig = ''
    set number
    set relativenumber
  '';
};

programs.vim = {
  enable = true;
  settings = { number = true; };
  extraConfig = ''
    set expandtab
    set shiftwidth=2
  '';
};

programs.emacs = {
  enable = true;
  extraPackages = epkgs: [ epkgs.nix-mode ];
};
```

### Terminal Tools

```nix
programs.git = {
  enable = true;
  userName = "Alice";
  userEmail = "alice@example.com";
  extraConfig = {
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
  };
  aliases = {
    st = "status";
    co = "checkout";
  };
};

programs.ssh = {
  enable = true;
  matchBlocks = {
    "github" = {
      host = "github.com";
      identityFile = "~/.ssh/id_ed25519";
    };
  };
};

programs.starship = {
  enable = true;
  enableBashIntegration = true;
  settings = {
    character.success_symbol = "[➜](bold green)";
  };
};

programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
  enableBashIntegration = true;
};

programs.fzf = {
  enable = true;
  enableBashIntegration = true;
};

programs.zoxide = {
  enable = true;
  enableBashIntegration = true;
};
```

### Desktop Applications

```nix
programs.firefox = {
  enable = true;
  profiles.default = {
    isDefault = true;
    settings = {
      "browser.startup.homepage" = "https://example.com";
    };
  };
};

programs.vscode = {
  enable = true;
  extensions = with pkgs.vscode-extensions; [
    bbenoist.nix
    rust-lang.rust-analyzer
  ];
  userSettings = {
    "editor.fontSize" = 14;
  };
};

programs.kitty = {
  enable = true;
  settings = {
    font_size = 12;
    background = "#1a1a1a";
  };
};

programs.wezterm = {
  enable = true;
  # Declarative settings (Home Manager 26.05+) — Nix attr sets serialized to Lua
  settings = {
    font_size = 12;
    color_scheme = "Gruvbox Dark";
    enable_tab_bar = true;
  };
  # Raw Lua expressions can be embedded with lib.generators.mkLuaInline
  extraConfig = ''''
    return {
      font = wezterm.font('JetBrains Mono'),
    }
  '''';
};
```

### Services

```nix
services.syncthing.enable = true;

services.gpg-agent = {
  enable = true;
  defaultCacheTtl = 1800;
  enableSshSupport = true;
};

services.dunst = {
  enable = true;
  settings = {
    global = {
      font = "Monospace 10";
      format = "<b>%s</b>\n%b";
    };
  };
};
```

## News and Release Tracking

Home Manager includes a **news system** that notifies you of breaking changes, deprecations, and new features when you run `home-manager build` or `switch`.

```bash
# View all current news items
home-manager news

# News is also shown automatically during switch/build when there are unread items
home-manager switch
```

Always review news items after updating your `home-manager` input, especially when tracking `master` or `nixos-unstable`.

## Dotfile Management

### `home.file` — The Swiss Army Knife

```nix
# Static file from store
home.file.".config/git/config".source = ./gitconfig;

# Inline text
home.file.".config/app/config.toml".text = ''
  [server]
  port = 8080
  host = "0.0.0.0"
'';

# Generated via pkgs.writeText
home.file.".config/app/config.json".source =
  pkgs.writeText "config.json" (builtins.toJSON {
    server = { port = 8080; };
  });

# Entire directory
home.file.".config/nvim".source = ./nvim-config;

# Recursive with file attributes
home.file.".screenrc" = {
  text = "defscrollback 10000";
  executable = false;
};
```

### Conditional Files

```nix
{ config, lib, pkgs, ... }:

{
  home.file.".config/hypr/hyprland.conf" = lib.mkIf config.wayland.windowManager.hyprland.enable {
    source = ./hyprland.conf;
  };
}
```

### Secrets (Avoid Plain Text)

**Never commit secrets to your Home Manager repo.**

| Method | Approach |
|--------|----------|
| `home.file` + git-crypt | Encrypt secrets in repo |
| `home.file` + sops-nix | Mozilla sops integration |
| `home.file` + agenix | Age-based secret encryption |
| Environment variables | Source at runtime |
| Secret service | `libsecret`, `pass`, `rbw` |

```nix
# Using sops-nix (requires sops-nix input in flake)
sops.secrets."api_key" = {};
home.sessionVariables.API_KEY = config.sops.secrets."api_key".path;
```

## Custom Modules

Extract reusable configuration into modules.

### Simple Module

```nix
# modules/dev-tools.nix
{ config, lib, pkgs, ... }:

{
  options.my.devTools.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.my.devTools.enable {
    home.packages = with pkgs; [
      git
      ripgrep
      fd
      fzf
      jq
    ];

    programs.git = {
      enable = true;
      userName = "Alice";
      userEmail = "alice@example.com";
    };
  };
}
```

### Using the Module

```nix
# home.nix or flake.nix
{
  imports = [ ./modules/dev-tools.nix ];

  my.devTools.enable = true;
}
```

### Module with Arguments

```nix
# modules/neovim-custom.nix
{ config, lib, pkgs, ... }:

{
  options.my.neovim = {
    enable = lib.mkEnableOption "custom neovim config";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "gruvbox";
      description = "Color theme";
    };
  };

  config = lib.mkIf config.my.neovim.enable {
    programs.neovim = {
      enable = true;
      extraConfig = ''
        colorscheme ${config.my.neovim.theme}
      '';
    };
  };
}
```

### Reusable Home Manager Module Output

Export modules from your flake for others to consume:

```nix
{
  outputs = { self, ... }: {
    homeManagerModules = {
      default = import ./modules/home;
      devtools = import ./modules/dev-tools.nix;
    };
  };
}
```

Others import it:

```nix
{
  inputs.your-flake.url = "github:yourname/your-flake";

  outputs = { self, nixpkgs, home-manager, your-flake, ... }: {
    homeConfigurations.alice = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        your-flake.homeManagerModules.devtools
        ./home.nix
      ];
    };
  };
}
```

## Advanced Patterns

### Per-Host Configuration

```nix
{ config, lib, pkgs, ... }:

let
  hostname = builtins.getEnv "HOSTNAME";
in {
  imports = lib.optional (builtins.pathExists ./hosts/${hostname}.nix)
    ./hosts/${hostname}.nix;

  # Or use hostname-based conditionals
  home.packages = lib.optionals (hostname == "workstation") [
    pkgs.blender
    pkgs.kdenlive
  ];
}
```

### Per-User Flake with `extraSpecialArgs`

```nix
# flake.nix
{
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      mkHome = { username, system, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username; };
          modules = [
            ./home.nix
          ] ++ extraModules;
        };
    in {
      homeConfigurations = {
        alice = mkHome { username = "alice"; system = "x86_64-linux"; };
        bob   = mkHome {
          username = "bob";
          system = "x86_64-linux";
          extraModules = [ ./modules/work-tools.nix ];
        };
      };
    };
}
```

```nix
# home.nix — uses the injected username
{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
}
```

### Overlays

```nix
# flake.nix
{
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          (final: prev: {
            my-custom-package = prev.callPackage ./pkgs/my-custom-package {};
          })
        ];
      };
    in {
      homeConfigurations.alice = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
```

### Nixpkgs Config (Allow Unfree)

```nix
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
    "discord"
  ];
}
```

## Generations and Rollback

```bash
# List all generations
home-manager generations

# Rollback to previous generation
home-manager switch --rollback

# Rollback to specific generation
home-manager switch --generation 42

# Delete old generations
home-manager remove-generations 1 2 3
home-manager remove-generations +7   # Keep last 7

# Garbage collect
nix-collect-garbage -d
```

## Troubleshooting

### "Existing file is in the way"

Home Manager refuses to overwrite files it did not create.

```bash
# Option 1: Back up and remove the file
mv ~/.bashrc ~/.bashrc.backup
home-manager switch

# Option 2: Force overwrite (use with caution)
home-manager switch -b backup  # Creates .backup files
```

### "Undefined variable"

```
error: undefined variable 'foo'
```

- Check spelling and case sensitivity
- Ensure the package exists in your nixpkgs version
- For custom packages, verify the overlay or import path

### "Option does not exist"

```
error: The option `programs.foo.bar' does not exist
```

- Check the Home Manager manual for the correct option path
- Ensure your Home Manager version supports the option
- Some options require enabling the parent: `programs.foo.enable = true;`

### Build Failures

```bash
# Verbose build output
home-manager switch --show-trace

# Build without activating
home-manager build

# Inspect the build
ls result/activation-script
```

### "Home directory mismatch"

```
error: Home directory mismatch
```

Ensure `home.homeDirectory` matches the actual home directory. On macOS, use `/Users/username` not `/home/username`.

### Slow Evaluation

```bash
# Use nix-eval-jobs for parallel evaluation
nix run nixpkgs#nix-eval-jobs -- --flake .#homeConfigurations.alice

# Or limit recursion depth
home-manager switch --max-jobs 4
```

## Best Practices

### Project Structure

```
home-manager/
├── flake.nix
├── home.nix
├── modules/
│   ├── dev-tools.nix
│   ├── shell.nix
│   └── desktop.nix
├── hosts/
│   ├── laptop.nix
│   └── desktop.nix
└── pkgs/
    └── custom-tool/
        └── default.nix
```

### Do's and Don'ts

| Do | Don't |
|----|-------|
| Use `home.stateVersion` and never change it | Change `stateVersion` after initial setup |
| Use program modules when available | Use `home.file` for everything |
| Pin nixpkgs and home-manager inputs | Use floating channels in flakes |
| Commit `flake.lock` | Commit secrets or `result` symlinks |
| Use `extraSpecialArgs` for per-user data | Hardcode usernames in shared modules |
| Test with `home-manager build` first | Run `switch` blindly on remote machines |
| Use `lib.mkIf` for conditional config | Comment out large blocks |
| Keep modules focused and reusable | Create one giant `home.nix` |

### Git Setup

```gitignore
# .gitignore
result
result-*
.direnv/
.envrc
*.swp
*.swo
*~
```

## Resources

| Resource | URL |
|----------|-----|
| Home Manager Manual | https://home-manager.dev/manual/unstable/ |
| Release Notes | https://home-manager.dev/manual/unstable/release-notes.xhtml |
| Option Search | https://home-manager-options.extranix.com/ |
| Source Code | https://github.com/nix-community/home-manager |
| NixOS Wiki | https://wiki.nixos.org/wiki/Home_Manager |
| Mailing List | https://discourse.nixos.org/c/learn/home-manager |
