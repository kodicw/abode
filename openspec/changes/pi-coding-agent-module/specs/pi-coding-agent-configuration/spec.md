## ADDED Requirements

### Requirement: Declarative pi-coding-agent module
The system SHALL provide a Home Manager module `programs.pi-coding-agent` for managing the installation and configuration of `pi-coding-agent`.

#### Scenario: Enabling pi-coding-agent
- **WHEN** `programs.pi-coding-agent.enable` is set to `true`
- **THEN** the `pi` package is added to user environment packages and `~/.pi/agent/settings.json` is generated with the configured `settings`.

### Requirement: Declarative settings.json generation
The `programs.pi-coding-agent.settings` option SHALL define the attributes written to `~/.pi/agent/settings.json`.

#### Scenario: Custom settings configuration
- **WHEN** `defaultProvider`, `defaultModel`, `defaultThinkingLevel`, and `packages` are specified under `programs.pi-coding-agent.settings`
- **THEN** the generated `~/.pi/agent/settings.json` accurately reflects these values.
