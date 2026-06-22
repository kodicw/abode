# abode

This repository contains the [Home Manager](https://github.com/nix-community/home-manager) configuration for my ChromeOS environment (Crostini/Linux development environment).

It uses Nix Flakes to provide a reproducible and declarative way to manage user-level packages, shell environments, and configuration files.

## Structure

```
home.nix                    # Main entry point
├── config/home.nix          # Basic home config (username, stateVersion)
├── packages.nix             # All Nix packages
├── programs/
│   ├── shells.nix           # Xonsh, Nushell, Bash, Starship, Carapace
│   ├── terminals.nix        # Ghostty, Zellij
│   └── devtools.nix         # Git, GitHub CLI, opencode, MCP, fastfetch
├── session.nix              # Environment variables
├── systemd/
│   ├── opencode-server.nix  # opencode headless server
│   └── rclone-gdrive.nix    # Google Drive FUSE mount
└── activation/
    └── crostini-icons.nix   # Crostini icon syncing
```

## Features
- **Nix Flakes**: For dependency management and reproducible builds.
- **Bash**: Primary interactive shell with Starship prompt and Carapace completion.
- **Nushell & Xonsh**: Alternative shells available for use.
- **Zellij**: Terminal multiplexer for workspace management.
- **Wayland Optimized**: Configuration for Ghostty terminal with Wayland-specific session variables.
- **Cloud Integration**: Automatic Google Drive mounting via `rclone` systemd service.

## Usage

To apply the configuration:

```bash
home-manager switch --flake .#kodicw
```

To update the flake inputs:

```bash
nix flake update
```