# Project Overview: abode

`abode` is a Nix Flake-based [Home Manager](https://github.com/nix-community/home-manager) configuration tailored for the user `kodicw`. It manages user-level packages, shell environments, terminal settings, and background services in a reproducible manner.

## Main Technologies & Architecture
- **Nix Flakes**: Used for dependency management and reproducible builds.
- **Home Manager**: Manages the user environment and dotfiles.
- **Bash**: The primary interactive shell.
- **Nushell & Xonsh**: Also installed and available as alternative shells.
- **Zellij**: Terminal multiplexer configuration.
- **Foot & Ghostty**: Terminal emulators.
- **rclone**: Configured as a systemd user service to mount Google Drive.
- **nixGL**: Used to provide hardware acceleration for GUI applications (e.g., `nixGLIntel`).
- **Nixvim**: Custom Neovim configuration provided via the `polarbear` flake.

## Building and Running

### Apply Configuration
To apply the Home Manager configuration to the current user:
```bash
home-manager switch --flake .#kodicw
```

### Update Dependencies
To update the flake inputs (like `nixpkgs` or `polarbear`):
```bash
nix flake update
```

### Environment Notes
- The configuration sets several Wayland-related session variables (`WAYLAND_DISPLAY`, `MOZ_ENABLE_WAYLAND`, etc.), suggesting a Wayland-native environment.
- It includes a `rclone-gdrive` systemd service that automatically mounts Google Drive to `~/gdrive`.

## Development Conventions

### Configuration Structure
- `flake.nix`: Defines the entry point, inputs, and output configurations.
- `home.nix`: The primary configuration file where packages, programs, and session variables are defined.

### Adding Packages
Packages should be added to the `home.packages` list in `home.nix`. If a package requires complex configuration, consider using a dedicated `programs.<name>` module if available in Home Manager.

### Shell Integration
- **Bash** is the default shell. Nushell and Xonsh are configured and available if needed.
- Custom aliases and functions should be defined within the `programs.xonsh`, `programs.nushell` or `programs.bash` sections in `home.nix`.
