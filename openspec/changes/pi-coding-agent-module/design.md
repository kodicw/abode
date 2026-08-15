## Context

Currently, the `pi` coding agent CLI settings are kept in unmanaged dotfiles (`~/.pi/agent/settings.json`). This requires manual editing and leaves state unversioned.

## Goals / Non-Goals

**Goals:**
- Leverage `programs.pi-coding-agent` provided by `inputs.agent-skills-nix.homeManagerModules.default`.
- Configure `package = llm-agents.packages.${system}.pi` and declarative settings in `modules/programs/ai.nix`.
- Generate `~/.pi/agent/settings.json` declaratively using Nix formatting helpers (`pkgs.formats.json`).

**Non-Goals:**
- Managing interactive chat session logs under `~/.pi/agent/sessions/` (these are dynamic runtime state).
- Storing secrets or API tokens in plain-text Nix expressions.

## Decisions

- **Module reuse**: Use `programs.pi-coding-agent` from `inputs.agent-skills-nix.homeManagerModules.default` (already imported via `modules/core/agent-skills.nix`).
- **Package source**: Set `package = llm-agents.packages.${system}.pi`.
- **Configuration location**: Configure in `modules/programs/ai.nix`.

## Risks / Trade-offs

- [Risk] Overwriting existing unmanaged `~/.pi/agent/settings.json`.
  - **Mitigation**: Home Manager will replace unmanaged file with managed symlink; existing configuration values (`opencode-go`, `deepseek-v4-flash`, `high`, `git:github.com/kodicw/pi-voice`) are preserved in Nix code.
