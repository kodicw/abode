# abode

Home Manager flake for ChromeOS/Crostini (Nix-on-Chromebook).

## Apply

```sh
home-manager switch --flake .#<user>
home-manager build --flake .#<user>   # dry-run
nix flake update                       # bump all inputs
```

5 profiles: `kodicw`, `charles`, `nixos`, `kodiwalls` (x86_64); `droid` (aarch64).
User configs are `config/users/<name>.nix` — simple 3-field attrsets (`username`, `homeDirectory`, `stateVersion`). Add a new user by creating that file and adding a `homeConfigurations` entry in `flake.nix`.

## Module layout

`self.homeManagerModules.default` bundles:

| Module | File |
|--------|------|
| config-home | `config/home.nix` |
| packages | `packages.nix` |
| programs-devtools | `programs/devtools.nix` |
| programs-shells | `programs/shells.nix` |
| programs-terminals | `programs/terminals.nix` |
| programs-ai | `programs/ai.nix` |
| session | `session.nix` |

Explicit-import-only (not in default): `activation-crostini-icons` (`activation/crostini-icons.nix`), `programs/csharp.nix`, `systemd/opencode-server.nix`, `systemd/rclone-gdrive.nix`.

## Quirks

- **Primary shell is Bash.** Nushell and Xonsh are also installed and available. Edit configs in `programs/shells.nix`.
- **Wayland session vars** in `session.nix` are set on x86_64 only (not aarch64/droid).
- **Crostini activation** skips `.desktop` files that already exist and don't reference `nixGLIntel` — prevents duplicate launcher entries.
- **`.gitignore`** only ignores `result`. No CI, no tests, no linters.
- **External flake**: `github:kodicw/polarbear` provides `nixvim` and `tools-ssh` packages.
- **`config/home.nix`** expects a `userModule` arg passed via `extraSpecialArgs` in `flake.nix`.
- **Recent commits** by "JBot (dev)" — an AI agent, not the human.
- **Herdr execution constraint**: When running inside the herdr multiplexer (e.g. when `HERDR_ENV=1` is set or herdr CLI is available), always execute terminal commands in a separate herdr pane (e.g. via `herdr pane run <pane> "<command>"`) instead of executing commands directly in the background or blocking the active agent's pane.

