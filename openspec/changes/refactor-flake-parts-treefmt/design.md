## Context

`abode` currently uses standard Nix flake syntax with manual `forAllSystems` loops and custom `mylib` imports in `flake.nix`. Migrating to `flake-parts` and `treefmt-nix` standardizes flake structure and formatting across system architectures.

## Goals / Non-Goals

**Goals:**
- Add `flake-parts`, `treefmt-nix`, and `systems` inputs to `flake.nix`.
- Rewrite `flake.nix` using `flake-parts.lib.mkFlake`.
- Use `treefmt-nix.flakeModule` to configure `nixfmt-rfc-style` and `shfmt`.
- Keep existing `homeConfigurations` (`kodicw`, `charles`, `nixos`, `kodiwalls`, `droid`, `charlyndavi`) and `homeManagerModules` fully functional.

**Non-Goals:**
- Changing existing module logic or homeConfiguration contents.

## Decisions

- **Framework**: Use `flake-parts.lib.mkFlake`.
- **System List**: Use `systems = import inputs.systems` (covering `x86_64-linux` and `aarch64-linux`).
- **Formatting**: `treefmt.programs.nixfmt-rfc-style.enable = true` and `treefmt.programs.shfmt.enable = true`.

## Risks / Trade-offs

- [Risk] Schema mismatch on flake outputs.
  - **Mitigation**: Verify `nix flake check` and `nix build .#homeConfigurations.droid.activationPackage` pass without error.
