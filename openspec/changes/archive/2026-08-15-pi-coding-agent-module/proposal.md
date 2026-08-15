## Why

Currently, `pi` (`pi-coding-agent`) configuration (e.g. `defaultProvider`, `defaultModel`, `defaultThinkingLevel`, installed packages/extensions) relies on unmanaged dotfiles in `~/.pi/agent/settings.json`. Configuring `programs.pi-coding-agent` via Home Manager allows declarative, reproducible configuration management across all user profiles in the `abode` flake.

## What Changes

- Utilize the `programs.pi-coding-agent` Home Manager module (provided via `inputs.agent-skills-nix.homeManagerModules.default`).
- Configure `programs.pi-coding-agent` in `modules/programs/ai.nix`:
  - `enable = true`
  - `package = llm-agents.packages.${system}.pi`
  - `settings` matching local state (`opencode-go`, `deepseek-v4-flash`, `high`, `git:github.com/kodicw/pi-voice`).
- Move existing local settings from `~/.pi/agent/settings.json` into Home Manager module declarations.

## Capabilities

### New Capabilities
- `pi-coding-agent-configuration`: Declarative Home Manager module for configuring `pi-coding-agent` CLI, settings, and packages.

### Modified Capabilities
None.

## Impact

- **Updated Modules**: `modules/programs/ai.nix`
- **State**: `~/.pi/agent/settings.json` is declaratively managed by Home Manager.
