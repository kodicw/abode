# Technical Design: Secret Management via SecretSpec & Pass CLI

## Context

Managing AI service secrets (e.g. Google Maps API keys, Gmail OAuth credentials) directly in Home Manager Nix expressions risks leaking credentials into the world-readable `/nix/store` or Git history. `abode` utilizes standard GPG agent and `pass` (`password-store`) for Unix password management. Integrating `secretspec` allows declaring required environment keys in `secretspec.toml` while reading GPG-encrypted secrets from `pass` at process invocation time.

## Goals / Non-Goals

**Goals:**
- Provide a `secretspec.toml` manifest in the project root defining standard secret bindings for Google/Gmail MCP servers.
- Enable `programs.password-store` in Home Manager (`modules/core/home.nix`).
- Provide wrapper functions in Home Manager to execute processes with secret injection via `secretspec` or direct `pass` lookups.
- Ensure Nix store outputs remain free of plaintext secrets.

**Non-Goals:**
- Replace GPG key management or `pass` vault storage backend.
- Commit actual plaintext GPG secrets to the git repository.

## Decisions

- **Decision 1: Use `secretspec.toml` for repo-level secret schemas**: We define `secretspec.toml` using `pass` provider paths (e.g., `path = "api/google/gmail_client_id"`).
- **Decision 2: Home Manager `programs.password-store` enabling**: We enable `programs.password-store` in `modules/core/home.nix` so `pass` CLI is natively managed.
- **Decision 3: Secret Injection Wrappers for MCP Servers**: In `modules/programs/ai.nix`, wrapper shell functions (e.g. `secretspec run -- ...`) or helper scripts execute MCP servers cleanly without embedding plaintext in nix files.

## Risks / Trade-offs

- [Risk] Unlocked GPG key required at process runtime → Mitigation: `gpg-agent` with `pinentry-curses` automatically prompts for passphrase when needed.
- [Risk] Missing pass entry at runtime → Mitigation: Wrapper scripts validate pass path existence or log helpful setup instructions.
