# Proposal: Secret Management via SecretSpec & Pass CLI

## Why

Storing raw API credentials (such as Google/Gmail OAuth client secrets or API keys) directly in Nix configuration files or world-readable `/nix/store` output derivations poses security risks. Integrating SecretSpec with the `pass` CLI allows declaring secret dependencies cleanly in the repository while resolving secret values safely at runtime via local GPG decryption without committing sensitive credentials to Git or Nix derivations.

## What Changes

- Add a declarative `secretspec.toml` configuration in the project root defining secret mappings to `pass` store paths (e.g. `api/google/gmail_client_id`, `api/google/gmail_client_secret`, `api/google/maps_api_key`).
- Enable `password-store` (`pass`) package management and `secretspec` tool configuration within Home Manager (`modules/core/packages.nix` & `modules/core/home.nix`).
- Provide wrapper scripts or environment hooks to execute AI tools and MCP servers with secret injection powered by SecretSpec and `pass`.

## Capabilities

### New Capabilities
- `secretspec-pass-integration`: Declarative runtime secret injection using SecretSpec and the `pass` password manager CLI for Home Manager configurations.

### Modified Capabilities
- None

## Impact

- `modules/core/home.nix`: Configures `programs.password-store`.
- `modules/core/packages.nix`: Adds `secretspec` to home packages.
- `secretspec.toml`: New repository specification mapping environment keys to `pass` paths.
- `modules/programs/ai.nix`: Updates MCP server execution pattern to leverage runtime secret resolution wrappers.
