## ADDED Requirements

### Requirement: Universal GPG configuration
All Home Manager user profiles MUST have GPG enablement and GPG agent enabled via the core configuration.

#### Scenario: GPG is enabled for base home-manager module
- **WHEN** any user profile imports the core config-home module
- **THEN** programs.gpg.enable is set to true

#### Scenario: GPG Agent is enabled for base home-manager module
- **WHEN** any user profile imports the core config-home module
- **THEN** services.gpg-agent.enable is set to true and pinentry.package is configured to pkgs.pinentry-curses

### Requirement: Clean devtools.nix
The GPG and GPG agent configurations MUST be removed from `modules/programs/devtools.nix` to prevent configuration duplication or conflicts.

#### Scenario: devtools.nix is evaluated
- **WHEN** evaluating `modules/programs/devtools.nix`
- **THEN** it does not define programs.gpg or services.gpg-agent
