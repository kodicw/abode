# abode — Home Manager configuration

# List available recipes
[private]
default:
    @just --list

# Switch to a user's home configuration
switch user:
    home-manager switch --flake .#{{user}}

# Dry-build a user's home configuration
build user:
    home-manager build --flake .#{{user}}

# Evaluate all flake checks
check:
    nix flake check

# Format all Nix files
fmt:
    nix fmt

# Update flake inputs
update:
    nix flake update
