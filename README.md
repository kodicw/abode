# abode

This repository contains the [Home Manager](https://github.com/nix-community/home-manager) configuration for my ChromeOS environment (Crostini/Linux development environment).

It uses Nix Flakes to provide a reproducible and declarative way to manage user-level packages, shell environments, and configuration files.

## Structure

```
├── modules/
│   ├── core/                # home, packages, session, agent-skills
│   ├── programs/            # shells, terminals (Ghostty, Zellij, Tmux), devtools, ai
│   ├── services/            # opencode-server, rclone-gdrive, maintenance, session-keepalive
│   ├── desktop/             # niri, shell
│   └── activation/          # crostini-icons
```

## Features
- **Nix Flakes**: For dependency management and reproducible builds.
- **Bash**: Primary interactive shell with Starship prompt and Carapace completion.
- **Nushell & Xonsh**: Alternative shells available for use.
- **Zellij & Tmux**: Terminal multiplexers for workspace management with `tmux-resurrect` and `tmux-continuum` auto-restoration.
- **Session Keep-Alive**: Prevents Linux VM session loss on Android / Crostini via systemd user lingering (`loginctl enable-linger`), background keep-alive daemon, persistent Tmux server, and SSH client keep-alives.
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