---
name: nix-nixos-guide
description: Comprehensive guide for Nix, NixOS, and Home Manager usage. Covers flakes, home-manager configurations, nixpkgs, and best practices. Use when working with Nix expressions, package management, system configuration, or troubleshooting Nix builds. This skill is specifically tailored for the abode Home Manager flake project.
---

# Nix / NixOS / Home Manager Guide

## Core Principles

- **Immutable packages**: Every Nix derivation is built from a pinned expression. No mystery versions.
- **Reproducible**: Same inputs → same outputs. `flake.lock` pins everything.
- **Declarative**: Describe desired state, Nix figures out how to get there.
- **Pure**: Builds run in isolated environments without network access (except `fetchurl`).

## Quick Commands

```bash
# General
nix flake check              # validate flake
nix flake update             # update all inputs
nix fmt                      # format with configured formatter

# Home Manager
home-manager switch --flake .#<user>     # apply config
home-manager build --flake .#<user>      # dry-run
home-manager news                        # show unread news

# NixOS
sudo nixos-rebuild switch --flake .#<host>
sudo nixos-rebuild build --flake .#<host>

# Package operations
nix shell nixpkgs#<pkg>      # ephemeral shell with package
nix run nixpkgs#<pkg>        # run package without installing
nix search nixpkgs <term>    # search packages
```

## Flake Structure

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    homeConfigurations.user = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;  # for proprietary software
      };
      modules = [ ./home.nix ];
    };
  };
}
```

## Home Manager Patterns (abode-specific)

### Adding a new user
Create `config/users/<name>.nix` with:
```nix
{
  username = "nameofuser";
  homeDirectory = "/home/nameofuser";
  stateVersion = "25.11";
}
```
Then add to `flake.nix`:
```nix
homeConfigurations.nameofuser = mkHome "x86_64-linux" "nameofuser";
```

### Adding packages
either `home.packages` in an existing module, or `config.home.packages` in `packages.nix`.

### Pure vs legacy packages
- **Pure**: `import nixpkgs { system = "..."; config.allowUnfree = true; }` — self-contained, no external `~/.config/nixpkgs/config.nix`
- **Legacy**: `nixpkgs.legacyPackages.''${system}` — inherits user's nixpkgs config (impure)

Use **pure** for reproducible configurations. This project uses pure packages.

## Nix Expression Language

```nix
# Attribute sets
{ foo = "bar"; baz = 42; }

# Lists
[ 1 2 3 ]

# Functions
x: x + 1
{ x, y }: x + y

# Let bindings
let x = 42; in x + 1

# With
with pkgs; [ hello git ]

# Optionals
lib.optional condition package
lib.optionals condition [ pkg1 pkg2 ]
```

## Common Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `attribute 'foo' missing` | Typo in package name or attr path | `nix search nixpkgs <name>` |
| `file 'default.nix' not found` | Wrong flake input URL | Check `inputs` block |
| `undefined variable` | Missing `with pkgs;` or `inherit` | Add scope |
| `cannot coerce set to string` | Using attr set where string expected | Access specific attr |
| infinite recursion | Circular module imports | Flatten imports, remove cycles |

## Crostini (Chromebook) Notes

- Activation script handles `.desktop` files — checks for `nixGLIntel` references to avoid duplicates
- Wayland env vars set in `session.nix` on x86_64 only
- Primary shell is **bash**; Nushell and Xonsh are available as alternatives.
- Use `nixGLIntel` (via polarbear) for GPU-accelerated apps

## Debugging Builds

```bash
# See what a derivation depends on
nix derivation show .#homeConfigurations.kodicw.activationPackage | jq ...

# Build verbosely
nix build .#homeConfigurations.kodicw.activationPackage -L

# Enter a failed build's shell
nix develop .#homeConfigurations.kodicw.activationPackage

# Check closures (disk usage)
nix path-info -Sh /nix/store/...-home-manager-generation
```

> **For abode-specific Home Manager patterns** (flake structure, user creation, state versioning), see the [home-manager-guide] (skills/home-manager-guide/SKILL.md).

## Updating Inputs

```bash
nix flake update                    # update all
nix flake lock --update-input nixpkgs   # update single input
```

After updating, always run:
```bash
nix flake check
just switch <user>   # if just is available, else home-manager switch --flake .#<user>
```

## Testing Changes

- Use `home-manager build` for dry-runs
- Use `nix flake check` for evaluation validation
- The `checks` output in this flake validates all home configurations
- Use `--show-trace` for detailed error output: `nix build .#... --show-trace`

## External References

- `man home-configuration.nix` — all Home Manager options
- `man configuration.nix` — NixOS options
- `nix flake --help`
- `home-manager --help`
