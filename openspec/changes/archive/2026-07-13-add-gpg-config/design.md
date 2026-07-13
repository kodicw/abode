## Context

Currently, `gpg` and `gpg-agent` are configured under the `devtools` module (`modules/programs/devtools.nix`). However, not all profiles import the `devtools` module (specifically, the `charlyndavi` profile does not). GPG is a core program/service that should be available to all users.

## Goals / Non-Goals

**Goals:**
- Move GPG and GPG Agent configuration to `modules/core/home.nix`.
- Remove GPG and GPG Agent from `modules/programs/devtools.nix` to avoid duplicate configuration.
- Verify that all profiles build successfully.

**Non-Goals:**
- Configure user-specific GPG keys declarative or change default pinentry package.

## Decisions

### Decision 1: Relocate GPG and GPG Agent to `modules/core/home.nix`
- **RATIONALE**: `home.nix` is the core base configuration imported by all Home Manager user configurations in the flake. Putting GPG and GPG-agent there ensures it is universally enabled for all users.
- **ALTERNATIVES CONSIDERED**:
  - Keep in `devtools.nix` and add `devtools` module to `charlyndavi` profile. (Rejected because `charlyndavi` is meant to be a minimal profile without developer tools).
  - Expose a separate `gpg` home-manager module and import it for all profiles individually. (Rejected because GPG is basic enough to belong in `home.nix` alongside other base settings).

## Risks / Trade-offs

- **[Risk]** `pinentry-curses` package might not be present or cause issues in GUI-only environments.
  - **Mitigation** `pinentry-curses` is standard, lightweight, and works fine in terminal sessions (even under Wayland/Niri).
