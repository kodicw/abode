---
name: codex
description: "Guide for Codex CLI — an AI coding assistant CLI. Covers invocation, flags, subcommands, models, sandbox, plugins, MCP, configuration, and workflows. Use when the user asks about Codex or wants to use Codex for coding tasks."
---

# Codex CLI — skill

**Codex CLI** (v0.142.3) is an AI coding assistant. It provides an interactive TUI for AI-assisted coding and supports non-interactive execution, code review, sandboxed command execution, and more.

Installed at `/home/kodicw/.nix-profile/bin/codex`.

## Quick Start

```bash
# Start an interactive session
codex

# Run a prompt and exit (non-interactive)
codex exec "your prompt"

# Run with a specific model
codex -m "gpt-5.5"

# Resume the most recent session
codex resume --last

# Continue a session picker
codex resume
```

## Flags

| Flag | Short | Description |
|---|---|---|
| `--model <model>` | `-m` | Model to use |
| `--config <key=value>` | `-c` | Override config value (dotted path) |
| `--cd <dir>` | `-C` | Working root directory |
| `--add-dir <dir>` | | Additional writable directories |
| `--sandbox <mode>` | `-s` | Sandbox policy: `read-only`, `workspace-write`, `danger-full-access` |
| `--image <file>` | `-i` | Attach image(s) to initial prompt (repeatable) |
| `--profile <name>` | `-p` | Use a named config profile |
| `--oss` | | Use open-source provider |
| `--local-provider <name>` | | Specify local provider (`lmstudio` or `ollama`) |
| `--search` | | Enable live web search |
| `--no-alt-screen` | | Disable alternate screen (inline TUI mode) |
| `--ask-for-approval <policy>` | `-a` | Approval policy: `untrusted`, `on-request`, `never`, `on-failure` |
| `--dangerously-bypass-approvals-and-sandbox` | | Skip all prompts and sandboxing (DANGEROUS) |
| `--enable <feature>` | | Enable a feature flag (repeatable) |
| `--disable <feature>` | | Disable a feature flag (repeatable) |
| `--strict-config` | | Error on unrecognized config fields |
| `--remote <addr>` | | Connect TUI to remote app server |
| `--image <file>` | `-i` | Attach image(s) to initial prompt |

## Subcommands

| Command | Description |
|---|---|
| `codex exec` | Run non-interactively (aliases: `e`) |
| `codex review` | Run a code review non-interactively |
| `codex login` | Manage login / authentication |
| `codex logout` | Remove stored authentication |
| `codex mcp` | Manage external MCP servers |
| `codex plugin` | Manage Codex plugins |
| `codex mcp-server` | Start Codex as an MCP server (stdio) |
| `codex app-server` | [Experimental] App server / related tooling |
| `codex remote-control` | [Experimental] App server daemon |
| `codex completion` | Generate shell completion scripts |
| `codex update` | Update Codex to the latest version |
| `codex doctor` | Diagnose installation, config, auth, runtime |
| `codex sandbox` | Run commands within a Codex-provided sandbox |
| `codex debug` | Debugging tools |
| `codex apply` | Apply latest diff as `git apply` |
| `codex resume` | Resume a previous session |
| `codex fork` | Fork a previous session |
| `codex archive` | Archive a saved session |
| `codex unarchive` | Unarchive a saved session |
| `codex delete` | Delete a saved session |
| `codex cloud` | [Experimental] Codex Cloud tasks |
| `codex exec-server` | [Experimental] Standalone exec-server |
| `codex features` | Inspect / enable / disable feature flags |
| `codex help` | Print help |

## Models

Set with `--model` or `-m` flag, or in `config.toml`:

```bash
codex -m "gpt-5.5"
codex -m "o3"
```

Open-source providers: `--oss` with `--local-provider lmstudio` or `--local-provider ollama`.

## Execution Modes

### Interactive Mode
```bash
codex                               # Start TUI
codex "build the feature"           # Start with initial prompt
codex -i image.png "describe this"  # Start with image
```

### Print / Non-Interactive Mode
```bash
codex exec "refactor this file"
codex exec -m "gpt-5.5" "analyze the code"
echo "list all files" | codex exec -
codex exec --output-last-message output.txt "summarize"
```

### Code Review Mode
```bash
# Review uncommitted changes
codex review --uncommitted

# Review changes against a branch
codex review --base main

# Review a specific commit
codex review --commit HEAD

# With custom instructions
codex review --uncommitted "Focus on security issues"
```

## Authentication

```bash
# Check status
codex login status

# Login with browser
codex login

# Login with API key from stdin
printenv OPENAI_API_KEY | codex login --with-api-key

# Login with access token
printenv CODEX_ACCESS_TOKEN | codex login --with-access-token
```

Current auth: Logged in using ChatGPT.

## Sandbox

```bash
# Run with read-only sandbox (safe)
codex -s read-only

# Write access to workspace only
codex -s workspace-write

# Full access (dangerous)
codex -s danger-full-access

# Run arbitrary commands in the sandbox
codex sandbox <command>
```

Sandbox modes:
- `read-only` — no disk writes allowed
- `workspace-write` — only the workspace directory is writable
- `danger-full-access` — full system access

## Configuration

**Config file**: `~/.codex/config.toml`

Current config:
```toml
model = "gpt-5.5"
model_reasoning_effort = "xhigh"

[projects."/home/kodicw/code/prophunt"]
trust_level = "trusted"

[features]
hooks = true
```

Override on-the-fly:
```bash
codex -c model="o3"
codex -c 'sandbox_permissions=["disk-full-read-access"]'
codex -c shell_environment_policy.inherit=all
```

Profiles: use `--profile <name>` to layer `$CODEX_HOME/<name>.config.toml` on top of base config.

### Hooks
Hooks are enabled (`features.hooks = true`). Hook config is stored at `~/.codex/hooks.json`.

### Trust Levels
Per-project trust is configured in `config.toml`:
```toml
[projects."/home/kodicw/code/prophunt"]
trust_level = "trusted"
```

## Plugins

```bash
# List installed plugins
codex plugin list

# Install a plugin from marketplace
codex plugin add <name>

# Manage marketplaces
codex plugin marketplace list
codex plugin marketplace add <url>

# Remove a plugin
codex plugin remove <name>
```

## MCP Servers

```bash
# List MCP servers
codex mcp list

# Get details
codex mcp get <name>

# Add an MCP server
codex mcp add <name> --config <config>

# Remove
codex mcp remove <name>

# Start Codex as an MCP server
codex mcp-server
```

## Session Management

```bash
# Resume picker (shows all recent sessions)
codex resume

# Resume most recent session
codex resume --last

# Resume specific session by ID or name
codex resume <session-id>

# Fork (branch) a previous session
codex fork
codex fork --last

# Archive / unarchive / delete
codex archive <session-id>
codex unarchive <session-id>
codex delete <session-id>

# Apply diff from a remote Cloud task
codex apply <task-id>
```

## Utility Commands

```bash
# Diagnose installation
codex doctor
codex doctor --json          # Machine-readable report
codex doctor --summary       # Compact view
codex doctor --all           # Full detail

# Generate shell completions
codex completion bash        # Bash completions
codex completion zsh         # Zsh completions
codex completion fish        # Fish completions

# Feature flags
codex features list
codex features enable <name>
codex features disable <name>
```

## Key Features

1. **Sandboxed execution**: Every agent-issued command runs in a sandbox by default, preventing accidental system modifications
2. **Approval policies**: Control when the agent needs permission to run commands (`untrusted`, `on-request`, `never`)
3. **Session persistence**: All sessions are saved; resume or fork them later
4. **Code review**: Built-in non-interactive code review against branches or commits
5. **MCP support**: Manage external MCP servers for extended tool capabilities
6. **Plugin marketplace**: Extend Codex with community plugins
7. **Config override**: Override any config value via CLI flags without editing files
8. **Trusted workspaces**: Mark projects as trusted to reduce permission prompts
9. **Remote mode**: Connect to a remote app server websocket
10. **Open-source providers**: Use LM Studio or Ollama for local models with `--oss`

## Tips

1. **Quick non-interactive**: `codex exec "prompt"` for scripts, pipes, or automation
2. **Review before commit**: `codex review --uncommitted` to catch issues before staging
3. **Sandbox safety**: Use `-s read-only` when exploring unknown code; `-s workspace-write` for active development
4. **Model switching**: Add `-m model-name` to try different models without changing config
5. **Resume workflows**: Use `codex resume --last` in automation to continue where you left off
6. **Diagnose issues**: `codex doctor --summary` quickly checks auth, config, and runtime health
7. **Images**: Attach screenshots with `-i screenshot.png` for visual context
8. **Web search**: Use `--search` to give the agent live web access
