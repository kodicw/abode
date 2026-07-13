## Why

Currently, GPG (`programs.gpg` and `services.gpg-agent`) is configured in the devtools module, which is not imported by all user profiles (e.g. `charlyndavi` profile). Adding GPG to the base Home Manager configuration ensures GPG and GPG agent are universally enabled for all configured user profiles.

## What Changes

- Extract GPG configurations (`programs.gpg` and `services.gpg-agent`) from `modules/programs/devtools.nix`.
- Enable GPG (`programs.gpg`) and GPG agent (`services.gpg-agent`) within the core `modules/core/home.nix` config, making it available to all user configurations.
- Ensure GPG configuration is styled cleanly.

## Capabilities

### New Capabilities
- `gpg-configuration`: Universally configures GPG and GPG Agent for all Home Manager profiles.

### Modified Capabilities

## Impact

- `modules/programs/devtools.nix`: Will no longer configure GPG and GPG Agent directly (removed to avoid duplicates/conflicts).
- `modules/core/home.nix`: Will import/configure GPG and GPG Agent for all users.
