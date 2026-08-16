# secretspec-pass-integration Specification

## Purpose
TBD - created by archiving change add-secretspec-pass. Update Purpose after archive.
## Requirements
### Requirement: Declarative Secret Mapping via SecretSpec
The system SHALL provide a `secretspec.toml` file mapping runtime environment variables to `pass` password store paths.

#### Scenario: SecretSpec mapping lookup
- **WHEN** process is executed via SecretSpec with `pass` provider
- **THEN** SecretSpec resolves the environment key from the specified `pass` path at runtime without storing plaintext in Nix store

### Requirement: Password Store Home Manager Module
The system SHALL enable `programs.password-store` in `modules/core/home.nix`.

#### Scenario: Enabling password-store
- **WHEN** Home Manager profile is activated
- **THEN** `pass` CLI is installed and available in user PATH

### Requirement: MCP Secret Injection Wrappers
The system SHALL provide helper scripts for launching Google/Gmail MCP servers with secret injection.

#### Scenario: Launching Google MCP server
- **WHEN** Google MCP wrapper script is executed
- **THEN** secrets are read from `pass` and passed in environment to the MCP server process

