## ADDED Requirements

### Requirement: Flake Parts Framework Integration
The `flake.nix` entrypoint SHALL use `flake-parts.lib.mkFlake` to organize per-system and top-level outputs.

#### Scenario: Evaluating flake outputs with flake-parts
- **WHEN** running `nix flake check` or `nix eval`
- **THEN** flake outputs are structured cleanly via `flake-parts` for supported systems (`x86_64-linux` and `aarch64-linux`).

### Requirement: Declarative Multi-System Formatting with treefmt-nix
The flake SHALL import `treefmt-nix.flakeModule` under `flake-parts` to provide unified code formatting.

#### Scenario: Formatter execution
- **WHEN** running `nix fmt`
- **THEN** `treefmt` runs `nixfmt-rfc-style` for Nix files and `shfmt` for shell scripts across all supported systems.
