---
name: justfile-guide
description: Comprehensive guide for the just command runner. Covers justfile syntax, recipes, variables, conditionals, dependencies, dotenv, and integration with Nix/Home Manager. Use when writing, debugging, or improving justfiles — especially for build automation, dev tasks, or replacing Makefiles.
---

# Just Command Runner Guide

## What is just?

`just` is a command runner — not a build system. It reads a `justfile` (or `Justfile`) and runs named recipes (commands).

- Recipes run with `sh` by default (or any interpreter you specify)
- Supports variables, conditionals, dependencies, and arguments
- Self-documenting: `just --list` shows all recipes with doc comments
- Cross-platform with good Windows support (via `powershell.exe` or `sh`)

## Installation

```bash
# Ephemeral
nix run nixpkgs#just

# Add to Home Manager (packages.nix)
with pkgs; [ just ]

# Or install locally
brew install just              # macOS
cargo install just             # Rust ecosystem
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash
```

## Basic Syntax

```just
# Comments start with #

# Variables
name := "world"
greeting := "hello"

# Default recipe (run when no recipe specified)
default:
    @echo "Usage: just <recipe>"
    @just --list

# Simple recipe
greet:
    echo "{{greeting}}, {{name}}!"

# Recipe with arguments
say message:
    echo "You said: {{message}}"

# Recipe with default argument
shout message="hello":
    echo "{{message | upper}}!!!"

# Dependencies (runs setup first)
build: setup
    cargo build --release

setup:
    rustup target add x86_64-unknown-linux-gnu
```

## Key Features

### Variables

```just
# Scalar
version := "1.0.0"

# Shell evaluation
branch := `git branch --show-current`
commit := `git rev-parse --short HEAD`

# Conditional
os := if os() == "macos" { "darwin" } else { os() }

# Environment fallback (with override)
target := env("BUILD_TARGET", "x86_64-linux")
```

### Recipes with Arguments

```just
# Positional
deploy env:
    echo "Deploying to {{env}}"
    # just deploy staging

# With defaults
test pattern="":
    cargo test {{pattern}}
    # just test              → cargo test ""
    # just test user         → cargo test user

# Multiple args
release version channel="stable":
    echo "Releasing {{version}} to {{channel}}"
    # just release 1.2.3 beta
```

### Dependencies

```just
# Linear dependencies (run in order)
all: lint test build

# Recipe with multiple deps
publish: build test
    cargo publish

# Settings for dependency parallelism
set allow-duplicate-recipes
```

### Conditionals & Functions

```just
# os() returns the OS: "macos", "linux", "windows"
# arch() returns the architecture: "aarch64", "x86_64", etc.
# invocation_directory() returns where just was invoked

# Conditional recipe
install:
    {{ if os() == "macos" { "brew install" } else { "apt-get install" } }} package

#
# String functions
#   `upper`, `lower`, `trim`, `replace`
# Path functions
#   `absolute_path`, `extension`, `file_name`, `parent_directory`, `without_extension`
```

### Modifiers

| Modifier | Effect |
|----------|--------|
| `@` | Suppress echo (recipe line not printed) |
| `-` | Ignore errors (continue on failure) |
| `+` | Run in interactive TTY |
| `=` | Export variable to recipe environment |

```just
quiet-task:
    @echo "This prints the output only"

ignore-errors:
    -cat nonexistent.txt  # continues even if cat fails
```

### Settings

At the top of the justfile:

```just
set shell := ["bash", "-cu"]
set dotenv-load := true
set export := true           # export all variables as env vars
set fallback := true         # search parent directories for justfile
set allow-duplicate-recipes  # allow multiple recipes with same name
```

### Dotenv Support

```just
set dotenv-load := true

deploy:
    echo "Deploying with API_KEY=$API_KEY"

# .env file in same directory:
# API_KEY=secret123
```

### Shebang Recipes (Arbitrary Interpreters)

```just
python-calc:
    #!/usr/bin/env python3
    import sys
    print(2 + 2)

node-script:
    #!/usr/bin/env node
    console.log("Hello from Node!");
```

## abode Project Patterns

> See the actual [`justfile`](https://github.com/kodicw/abode/blob/main/justfile) in the project root — it follows these patterns.

Additional recipes not in the project justfile:

```just
# Clean old generations (keep last 5)
clean:
    home-manager generations | tail -n +6 | cut -d' ' -f7 | xargs -I{} home-manager remove-generations {}

# Full maintenance cycle
maintain user: update fmt check
    just switch {{user}}
```

## Command Reference

| Command | Description |
|---------|-------------|
| `just` | Run default recipe |
| `just <recipe>` | Run specific recipe |
| `just <recipe> arg1 arg2` | Run with arguments |
| `just --list` | List all recipes |
| `just --show <recipe>` | Show recipe without running |
| `just --dry-run <recipe>` | Print what would run |
| `just --evaluate` | Print evaluated variables |
| `just --unstable` | Enable unstable features |
| `just --justfile <path>` | Use specific justfile |
| `just --working-directory <dir>` | Run in different directory |

## Common Patterns

### Nix Flake Wrapper

```just
flake-dir := "~/.config/home-manager/abode"

[private]
cd-flake:
    cd {{flake-dir}}

switch user: cd-flake
    home-manager switch --flake {{flake-dir}}#{{user}}
```

### Environment-Specific Config

```just
deploy env="dev":
    {{if env == "prod" { "echo 'PROD DEPLOY'" } else { "echo 'Dev deploy'" }}}
```

### Recipe Groups

```just
# Nix development
fmt-check:
    nix fmt -- --check

validate: fmt-check
    nix flake check

# Build pipeline
build-user user:
    home-manager build --flake .#{{user}}

switch-user user: build-user
    home-manager switch --flake .#{{user}}

# Full pipeline
release user: validate build-user
    just switch-user {{user}}
```

### Error Handling

```just
# Fail fast
strict-task:
    set -euo pipefail
    ./script.sh
    ./other.sh

# Or use bash explicitly
set shell := ["bash", "-euo", "pipefail", "-c"]
```

## Pitfalls & Gotchas

| Issue | Solution |
|-------|----------|
| `unknown attribute` | Check justfile syntax; `[]` is for arrays in settings, not annotations |
| Arguments not passed | Use `{{arg}}` interpolation, not shell `$1` |
| Recipe not showing in `--list` | Add doc comment above recipe, not `[private]` attribute unless intended |
| Variable not expanding in backticks | Use `{{variable}}` or ensure backticks are in assignment context |
| Windows issues | Use `just --shell powershell.exe` or set `set windows-powershell := true` |
| `just` not found | Install it or use `nix run nixpkgs#just -- <recipe>` |

## VS Code Integration

Install the "Just" extension by `skellock` (or similar) for syntax highlighting and recipe navigation.

## External References

- `just --help` — full CLI reference
- `man just` — man page
- https://just.systems/man/en/ — official book
- https://github.com/casey/just — source code and issues
