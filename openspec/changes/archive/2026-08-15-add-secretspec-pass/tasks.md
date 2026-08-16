## 1. Password Store & SecretSpec Declaration

- [x] 1.1 Enable `programs.password-store` in `modules/core/home.nix`
- [x] 1.2 Add `secretspec.toml` manifest in project root for `pass` secret mappings

## 2. MCP Secret Wrapper Integration

- [x] 2.1 Implement MCP secret injection wrappers for Google/Gmail servers in `modules/programs/ai.nix`
- [x] 2.2 Verify evaluation and Home Manager activation via `home-manager build`
