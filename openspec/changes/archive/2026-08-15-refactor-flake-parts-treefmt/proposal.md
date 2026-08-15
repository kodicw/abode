## Why

Refactoring `flake.nix` to use `flake-parts` and `treefmt-nix` modernizes the codebase, eliminates custom multi-system iteration boilerplate, and provides declarative, multi-system formatting and devShell support across `x86_64-linux` and `aarch64-linux`.

## What Changes

- Add `flake-parts` (`github:hercules-ci/flake-parts`), `treefmt-nix` (`github:numtide/treefmt-nix`), and `systems` (`github:nix-systems/default`) to `flake.nix` inputs.
- Refactor `flake.nix` to use `flake-parts.lib.mkFlake`.
- Integrate `treefmt-nix.flakeModule` into `flake-parts` to declaratively configure `nixfmt-rfc-style` for Nix and `shfmt` for Bash scripts.
- Expose multi-system `perSystem` outputs (formatting, packages, devShells) and top-level `flake` outputs (`homeConfigurations`, `homeManagerModules`, `lib`).

## Capabilities

### New Capabilities
- `flake-parts-architecture`: Modular `flake-parts` framework for multi-system outputs and declarative formatting with `treefmt-nix`.

### Modified Capabilities
None.

## Impact

- **flake.nix**: Modernized to use `flake-parts.lib.mkFlake`.
- **flake.lock**: Added `flake-parts`, `treefmt-nix`, and `systems`.
- **Multi-system**: Declarative handling of `x86_64-linux` and `aarch64-linux`.
