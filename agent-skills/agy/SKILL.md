---
name: agy
description: "Guide for the Antigravity CLI tool (agy) — an AI coding assistant CLI. Covering invocation, flags, subcommands, models, plugins, configuration, and keybindings. Use when the user asks about agy, Antigravity CLI, or wants to invoke agy for coding tasks."
---

# agy — Antigravity CLI skill

The **Antigravity CLI** (`agy`) is an AI coding assistant command-line tool. It's installed at `~/.nix-profile/bin/agy` (v1.0.16) and provides an interactive TUI for AI-assisted coding workflows.

## Quick Start

```bash
# Start interactive session
agy

# Run a single prompt and print response (non-interactive)
agy -p "your prompt"

# Start interactive with an initial prompt
agy -i -p "your prompt"

# Continue the most recent conversation
agy -c

# Resume a specific conversation by ID
agy --conversation <id>

# Start with a specific project
agy --project <project-id>

# Create a new project
agy --new-project
```

## Flags

| Flag | Short | Description |
|---|---|---|
| `--print "prompt"` | `-p` | Run a single prompt non-interactively and print response |
| `--print-timeout <duration>` | | Timeout for print mode (default 5m) |
| `--prompt-interactive` | `-i` | Run initial prompt then continue interactively |
| `--continue` | `-c` | Continue the most recent conversation |
| `--conversation <id>` | | Resume a specific conversation by ID |
| `--model <model>` | | Set model for the session |
| `--project <id>` | | Project ID for the session |
| `--new-project` | | Create a new project for this session |
| `--add-dir <path>` | | Add a directory to the workspace (repeatable) |
| `--sandbox` | | Run in a sandbox with terminal restrictions |
| `--dangerously-skip-permissions` | | Auto-approve all tool permission requests |
| `--log-file <path>` | | Override CLI log file path |

## Subcommands

| Command | Description |
|---|---|
| `agy changelog` | Show changelog and release notes |
| `agy help` | Show help for subcommands |
| `agy install` | Configure environment paths and shell settings |
| `agy models` | List available models |
| `agy plugin` | Manage plugins (install, uninstall, list, enable, disable) |
| `agy plugins` | Alias for `plugin` |
| `agy update` | Update CLI |

## Available Models

As of v1.0.16:

- **Gemini 3.5 Flash** (Medium, High, Low tiers)
- **Gemini 3.1 Pro** (Low, High tiers)
- **Claude Sonnet 4.6** (Thinking)
- **Claude Opus 4.6** (Thinking)
- **GPT-OSS 120B** (Medium)

Set the model with `--model` flag or via the `/model` command inside the TUI.

## Configuration

Located at `~/.gemini/antigravity-cli/settings.json`:

```json
{
  "model": "Claude Opus 4.6 (Thinking)",
  "toolPermission": "always-proceed",
  "artifactReviewPolicy": "always-proceed",
  "enableTelemetry": false,
  "trustedWorkspaces": ["/home/kodicw/code/prophunt"],
  "statusLine": {
    "type": "",
    "command": "",
    "enabled": true
  }
}
```

Key settings:
- `model` — default model for sessions
- `toolPermission` — permission policy for tool execution (`"always-proceed"` skips confirmation)
- `artifactReviewPolicy` — artifact review behavior
- `trustedWorkspaces` — directories trusted for agent operations
- `statusLine` — custom status line configuration

### Environment Variables

- `AGY_CLI_HIDE_ACCOUNT_INFO` — hide email and plan tier from header
- `AGY_CLI_DISABLE_LATEX` — disable LaTeX math rendering
- `AGY_CLI_CMD_OUTPUT_PERCENTAGE` — max height of command outputs as % of terminal height

### Log File

CLI logs are at: `~/.gemini/antigravity-cli/cli.log`

## Plugin System

```bash
# List installed plugins
agy plugin list

# Install a plugin
agy plugin install <source>

# Uninstall a plugin
agy plugin uninstall <name>

# Enable/disable a plugin
agy plugin enable <name>
agy plugin disable <name>
```

Plugins are installed to `~/.gemini/config/` and can include custom skills, agents, and MCP servers.

### Skills

Custom skills go in `~/.gemini/config/skills/`. The existing skill there is `herdr`.

## Keybindings

Custom keybindings are defined in `~/.gemini/antigravity-cli/keybindings.json`. Default keybindings include:

| Key | Action |
|---|---|
| `ctrl+c` | Interrupt active operation / double-press to exit |
| `ctrl+d` | Forward-delete (with text) / exit (empty prompt) |
| `ctrl+o` | Show scrollback / startup help |
| `ctrl+r` | Open Artifact Review panel |
| `ctrl+g` | Open $EDITOR on artifact view |
| `ctrl+k` | Scroll up |
| `alt+j` / `alt+v` | Paste (alt+v for Windows) |
| `Esc` | Interrupt streaming / clear input |
| `PageUp/PageDown` | Scroll in help and list views |

## TUI Commands (inside agy)

Inside the interactive TUI, use slash commands:

- `/model` — switch model
- `/settings` or `/config` — configure settings
- `/help` — view help and keybindings
- `/resume` — resume previous conversations
- `/tasks` — view background tasks
- `/diff` — view diffs
- `/permissions` — manage tool permission rules
- `/credits` — view and purchase credits
- `/changelog` — show CLI changelog
- `/add-dir` — add a workspace directory
- `/btw` — various utility commands
- `/keybindings` — customize keybindings
- `/statusline` — configure status line
- `/hooks` — manage pre/post hooks
- `/open` — open files with path autocompletion

## Tips

1. **Print mode**: Use `agy -p "prompt"` for quick non-interactive queries — useful in scripts or pipes
2. **Resume**: Use `agy -c` to pick up where you left off
3. **Project isolation**: Use `--project` and `--new-project` to keep conversations organized per codebase
4. **Permissions**: Use `--dangerously-skip-permissions` or set `toolPermission: "always-proceed"` for fully automated workflows, but be cautious
5. **Sandbox**: Use `--sandbox` when running untrusted code to restrict terminal access
6. **Logs**: Check `~/.gemini/antigravity-cli/cli.log` for debugging startup or session issues
7. **Model selection**: Use `--model "Claude Opus 4.6 (Thinking)"` for the most capable model, or `--model "GPT-OSS 120B (Medium)"` for lighter tasks
