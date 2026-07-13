## 1. GPG Configuration Relocation

- [x] 1.1 Remove GPG and GPG Agent from `modules/programs/devtools.nix`
- [x] 1.2 Configure GPG and GPG Agent in `modules/core/home.nix`

## 2. Validation & Formatting

- [x] 2.1 Format the updated files using `nix fmt`
- [x] 2.2 Verify the `charlyndavi` profile builds successfully using `home-manager build --flake .#charlyndavi`
- [x] 2.3 Verify the `kodicw` profile builds successfully using `home-manager build --flake .#kodicw`
