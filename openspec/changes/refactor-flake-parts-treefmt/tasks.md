## 1. Flake Inputs & Refactoring

- [x] 1.1 Add `flake-parts`, `treefmt-nix`, and `systems` inputs to `flake.nix`.
- [x] 1.2 Refactor `flake.nix` to use `flake-parts.lib.mkFlake` with `treefmt-nix.flakeModule`.
- [x] 1.3 Configure `treefmt` settings for `nixfmt-rfc-style` and `shfmt`.

## 2. Verification & Lock Update

- [x] 2.1 Run `nix flake update` to lock new inputs and test `nix flake check`.
- [x] 2.2 Test `nix fmt` to confirm formatting works cleanly.
