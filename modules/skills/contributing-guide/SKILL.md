---
name: contributing-guide
description: Guide for creating comprehensive CONTRIBUTING.md files. Covers commit conventions (Conventional Commits), branch strategy, TDD, code style enforcement, git hooks, PR processes, and community standards. Use when setting up a new project, onboarding contributors, or establishing engineering practices.
---

# Contributing Guide Authoring

Use this skill to create a thorough `CONTRIBUTING.md` for any project. The guide covers commit standards, testing practices, code style, hooks, and the PR workflow.

## File Structure

```
CONTRIBUTING.md
├── Commit Messages (Conventional Commits)
├── Branch Strategy
├── Test-Driven Development
├── Code Style & Formatting
├── Git Hooks
├── Pull Request Process
├── Hook Installation
└── Community & Security
```

## 1. Commit Messages

All commits should follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

### Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Types

| Type | Use when |
|------|----------|
| `feat` | New user-facing feature |
| `fix` | Bug fix |
| `refactor` | Code restructure, no behavior change |
| `test` | Adding or correcting tests |
| `chore` | Dependencies, tooling, flakes |
| `docs` | Documentation only |
| `perf` | Performance improvement |
| `ci` | CI/CD or hook changes |
| `revert` | Reverting a previous commit |

### Subject Rules

- Imperative mood, present tense: **"add handler"** not "added handler"
- No capital first letter
- No trailing period
- Max 72 characters for the first line

### Examples

```
feat(cli): add python template support
fix(auth): handle missing token gracefully
refactor(nix): simplify flake outputs structure
test(core): add integration test for project creation
chore(deps): bump nixpkgs input to 24.11
docs: add usage examples for custom templates
```

### Body and Footers

Use the body to explain **why**, not what. The diff explains what.

Footer tokens:

| Token | Purpose |
|-------|---------|
| `Closes #N` | Links and closes an issue |
| `Refs #N` | References without closing |
| `BREAKING CHANGE:` | Documents breaking API/schema change |

## 2. Branch Strategy

Use **trunk-based development** with short-lived feature branches. `main` is always releasable.

### Branch Naming

```
<type>/<short-description>
```

Same type vocabulary as commits. Kebab-case, max 5 words.

```
feat/add-python-template
fix/cli-template-resolution
refactor/flake-outputs-structure
chore/bump-nixpkgs-2411
docs/template-usage-guide
```

### Rules

- **Never commit directly to `main`** — all changes through PR
- **One concern per branch** — split mixed-concern branches
- **Rebase on `main` before merge** — linear history, no merge commits
- **Delete branches after merge** — stale branches are noise
- **Branches >3 days need explanation** in PR

### Protected Branch: `main`

- Passing CI (`nix flake check` or equivalent)
- PR review required
- No force-push
- Linear history enforced

## 3. Test-Driven Development

Strict TDD: **Red → Green → Refactor**, no exception.

```
┌─────────────────────────────────────────────┐
│  1. RED    Write a failing test that        │
│            describes desired behavior.        │
│            Run it. Watch it fail.             │
│                                               │
│  2. GREEN  Write minimum production code     │
│            to make the test pass.             │
│            No more, no less.                  │
│                                               │
│  3. REFACTOR Clean up. Extract, rename,     │
│            simplify. Tests stay green.        │
│                                               │
│            Repeat for next behavior.          │
└─────────────────────────────────────────────┘
```

### Test Layers

| Layer | Scope | Tool | Speed |
|-------|-------|------|-------|
| **Unit** | Single function/type, no I/O | `cargo test`, `pytest`, `jest` | ~seconds |
| **Integration** | Module interactions, real I/O | `nixosTest`, `bats`, `playwright` | ~minutes |
| **E2E** | Full user workflows | `playwright`, `cypress`, manual | ~10min+ |

### What Requires a Test First

| Change | Required test |
|--------|---------------|
| New CLI flag | Unit test |
| New public API | Unit + integration |
| Bug fix | Unit test reproducing the bug |
| New template/module | Integration test |

### What Does Not Need a Test First

- Documentation changes
- Formatting (no behavior change)
- Comment rewrites
- Dependency bumps (unless fixing a bug)

## 4. Code Style & Formatting

The formatter is **authoritative**. No manual formatting debates.

### Rust

```bash
cargo fmt              # Format
cargo fmt -- --check   # Check only
cargo clippy -- -D warnings  # Lint (treat warnings as errors)
```

Recommended `Cargo.toml` lints:

```toml
[lints.clippy]
unwrap_used = "warn"
panic = "warn"
todo = "warn"
dbg_macro = "warn"
print_stdout = "warn"
```

### Nix

```bash
nixfmt flake.nix **/*.nix        # Format
nixfmt --check flake.nix         # Check only
statix check .                   # Lint anti-patterns
```

### TypeScript / JavaScript

```bash
npx prettier --write .           # Format
npx eslint .                     # Lint
```

### Python

```bash
ruff format .                    # Format
ruff check .                     # Lint
mypy src/                        # Type check
```

### Go

```bash
gofmt -w .                       # Format
go vet ./...                     # Lint
staticcheck ./...                # Advanced lint
```

## 5. Git Hooks

Store hooks in `.githooks/` (checked into repo). Activate via:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/*
```

Or via dev shell `shellHook`:

```nix
shellHook = "git config core.hooksPath .githooks; chmod +x .githooks/*"
```

### Hook: `pre-commit`

Runs on every `git commit`. Blocks if checks fail.

**Typical checks (adapt to your stack):**

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[pre-commit] Running checks..."

# 1. Format check
cargo fmt -- --check        # or: npx prettier --check . ; ruff format --check .

# 2. Lint
cargo clippy -- -D warnings # or: npx eslint . ; ruff check . ; go vet ./...

# 3. Static analysis
statix check .              # or: shellcheck scripts/*.sh

# 4. Unit tests
cargo test --quiet          # or: pytest -q ; go test ./...

echo "[pre-commit] All checks passed."
```

### Hook: `commit-msg`

Validates Conventional Commits format.

```bash
#!/usr/bin/env bash
set -euo pipefail

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Allow merge/revert/fixup through
if echo "$COMMIT_MSG" | grep -qE "^(Merge|Revert|fixup!|squash!)"; then
  exit 0
fi

PATTERN="^(feat|fix|refactor|test|chore|docs|perf|ci|revert)(\([a-z0-9/-]+\))?(!)?: .{1,72}$"
FIRST_LINE=$(echo "$COMMIT_MSG" | head -n 1)

if ! echo "$FIRST_LINE" | grep -qE "$PATTERN"; then
  echo "FAIL: Commit message must follow Conventional Commits."
  echo "Expected: <type>(<scope>): <subject>"
  echo "Got:      $FIRST_LINE"
  exit 1
fi

# No capital first letter
SUBJECT=$(echo "$FIRST_LINE" | sed 's/^[^:]*: //')
FIRST_CHAR=$(echo "$SUBJECT" | cut -c1)
if echo "$FIRST_CHAR" | grep -qE "[A-Z]"; then
  echo "FAIL: Subject must start with lowercase."
  exit 1
fi

# No trailing period
if echo "$FIRST_LINE" | grep -qE '\.$'; then
  echo "FAIL: Subject must not end with a period."
  exit 1
fi

exit 0
```

### Hook: `pre-push`

Runs full integration suite before push.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[pre-push] Running full check suite..."

nix flake check --print-build-logs  # or: pytest tests/integration ; npm run e2e

echo "[pre-push] All checks passed. Pushing."
```

### Bypassing Hooks

Only for emergencies. The CI pipeline will catch the same failures.

```bash
git commit --no-verify -m "wip: debugging hook issue"
git push --no-verify
```

## 6. Pull Request Process

### Opening a PR

1. Rebase on latest `main`:
   ```bash
   git fetch origin
   git rebase origin/main
   ```
2. Ensure all local hooks pass
3. PR title follows Conventional Commits:
   ```
   feat(cli): add python template support
   ```
4. Fill in description:
   - **What:** One-sentence summary
   - **Why:** Feature/bug context
   - **How:** Non-obvious decisions
   - **Tests:** Coverage summary

### Review Checklist

Reviewers verify:

- [ ] New behavior covered by tests written first
- [ ] No naked `unwrap()` without `.expect("reason")`
- [ ] No debug prints left in committed code
- [ ] Formatter and linter pass
- [ ] Commit messages follow Conventional Commits
- [ ] PR title follows Conventional Commits
- [ ] Full CI suite passes

### Merge Strategy

All PRs are **squash-merged** into `main`. The squash commit message is the PR title. Individual branch commits are squashed away but should still pass hooks for good hygiene.

## 7. Language-Specific Templates

### Rust Project Example

```markdown
## Running Tests

```bash
cargo test              # Unit tests
cargo test -- --nocapture  # With output
cargo test test_name    # Single test
nix flake check         # Full integration (QEMU VM)
```

## Dependencies

Managed via `Cargo.toml` and `flake.nix`. Do not edit `Cargo.lock` manually.

## Release Builds

```bash
cargo build --release
nix build .#default     # Nix release build
```
```

### Nix Project Example

```markdown
## Running Checks

```bash
nix flake check         # Full check suite
nixfmt --check .        # Format check
statix check .          # Lint check
```

## Adding Packages

Add to `packages.nix`, import in `flake.nix`. Follow existing naming.
```

### TypeScript/Node Example

```markdown
## Running Tests

```bash
npm test                # Unit tests
npm run test:integration # Integration tests
npm run lint            # ESLint + Prettier
npm run typecheck       # TypeScript check
```

## Adding Dependencies

```bash
npm install package-name
```
Commit `package-lock.json` changes.
```

## 8. Community & Security

Reference these adjacent documents:

| Document | Purpose |
|----------|---------|
| `CODE_OF_CONDUCT.md` | Community behavior standards |
| `SECURITY.md` | Vulnerability reporting process |
| `SUPPORT.md` | How to get help |
| `GOVERNANCE.md` | Decision-making process |
| `CHANGELOG.md` | Notable changes tracking |

## Pitfalls

| Issue | Solution |
|-------|----------|
| Contributors commit to `main` directly | Enable branch protection rules |
| Commit messages inconsistent | Use the `commit-msg` hook |
| Formatting debates in PRs | Let the formatter be the authority |
| Tests written after code | Enforce TDD in PR checklist |
| Hooks too slow | Split heavy checks to `pre-push` |
| Contributors skip hooks | CI gates on `main` catch everything |
| Contributing guide outdated | Update it when process changes |

## Creating a New CONTRIBUTING.md

When asked to create a `CONTRIBUTING.md`:

1. Determine the project's primary language/stack
2. Adapt the commit conventions and branch strategy sections (language-agnostic)
3. Write the TDD section with the project's test commands
4. Fill the Code Style section with the project's formatter and linter
5. Write hook scripts for the project's stack
6. Include the PR process checklist
7. Add language-specific onboarding (dependencies, build, test)
8. Reference adjacent community files (CoC, Security, etc.)

The guide should be copy-paste ready for a new contributor on day one.
