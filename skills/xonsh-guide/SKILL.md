---
name: xonsh-guide
description: Comprehensive guide for xonsh, a Python-powered shell. Covers configuration, syntax, interoperability with bash/nix, prompt customization, and integration with starship, zoxide, carapace, and atuin. Use when configuring shells, writing xonsh rc files, debugging shell behavior, or migrating from bash/zsh to xonsh.
---

# Xonsh Guide

## What is xonsh?

Xonsh is a shell that combines Python's expressive power with shell syntax. Write Python in your shell, and shell in your Python.

- Full Python expressions anywhere: `$(echo hello).upper()`
- Subprocess capture: `$(cmd)`, `$[cmd]`, `$?`
- Cross-platform (Linux, macOS, Windows)
- Extensible: write functions, import modules, use pip packages

This project uses xonsh as the **primary interactive shell** — bash auto-execs into it.

## Configuration

Xonsh reads `~/.xonshrc` on startup. In this project it's managed by Home Manager:

```python
$UPDATE_OS_ENVIRON = True      # Sync Nix env vars into Python os.environ
$XONSH_SHOW_DOT_CHAR = True    # Show dot for hidden files in completion

aliases['ls'] = 'eza'
aliases['cat'] = 'bat -p'

execx($(starship init xonsh))
execx($(zoxide init xonsh))
execx($(carapace _carapace xonsh))
execx($(atuin init xonsh))
```

## Bash Auto-Exec Setup

Bash `~/.bashrc` contains:
```bash
if [[ $- == *i* ]] && [[ $(ps -p $PPID -o comm=) != "xonsh" ]] && command -v xonsh >/dev/null; then
  exec xonsh
fi
```

This means:
- Interactive bash sessions (`$- == *i*`) check if parent is already xonsh
- If not, replace bash process with xonsh (`exec`)
- Prevents nested xonsh shells

## Syntax Quick Reference

### Subprocesses

| Syntax | Meaning | Example |
|--------|---------|---------|
| `$(cmd)` | Capture stdout as string | `path = $(which git).strip()` |
| `$[cmd]` | Run in subprocess, no capture | `$[vim file.py]` |
| `$?` | Exit code of last command | `if $? == 0:` |
| `$()` | Run and return output lines | `files = $(ls)` |
| `$@(cmd)` | Run and return as argument list | `cp $@(echo a b c) dest/` |

### Environment Variables

```python
$PATH = [$PATH[0], "/custom/bin", *$PATH[1:]]
$EDITOR = "nvim"
del $OLD_VAR              # unset
for key, val in ''${...}.items():   # iterate all env vars
    print(key, val)
```

### Python in the Shell

```python
# Any valid Python works
import json; json.dumps({"key": "value"})

# List comprehension
files = [f for f in `.*` if f.endswith('.py')]

# Functions become commands
def greet(name):
    print(f"Hello, {name}!")

greet world    # works in shell!
```

### Prompt Customization

Xonsh uses `$PROMPT` for the prompt string:

```python
$PROMPT = "{BOLD_BLUE}{cwd}{RESET} {BOLD_GREEN}❯{RESET} "

# Or use starship (recommended in this project)
execx($(starship init xonsh))
```

## Integration with Tools

These tools are configured via `execx()` in your `.xonshrc` (see Configuration section above):

| Tool | Purpose |
|------|---------|
| **Starship** | Prompt customization |
| **Zoxide** | `z` command for directory jumping |
| **Carapace** | Rich tab-completions for 100+ CLI tools |
| **Atuin** | Ctrl+R for fuzzy history search |

### Direnv
```python
# Automatically loaded via $UPDATE_OS_ENVIRON
# Or use: execx($(direnv hook xonsh))
```

## Aliases

```python
# Simple command
aliases['ll'] = 'ls -la'

# Function alias
def _my_cmd(args):
    import subprocess
    subprocess.run(['git', 'status'] + args)
aliases['gs'] = _my_cmd

# Remove
del aliases['ll']
```

## Xontribs (Extensions)

```python
# Install: xpip install xontrib-autosuggestions
xontrib load autosuggestions
xontrib load vox            # virtualenv manager
xontrib load docker_tabcomplete
xontrib load whole_word_jumping
```

Common xontribs:
| Name | Purpose |
|------|---------|
| `autosuggestions` | Fish-like suggestions |
| `vox` | Python virtualenv manager |
| `abbrevs` | Expanding abbreviations |
| `sh` | Bash compatibility layer |
| `powerline` | Powerline prompt |

## Debugging

```python
# Trace execution
$XONSH_TRACE_SUBPROC = True

# Debug level
$XONSH_DEBUG = 1    # 1-3

# Show all loaded config files
xonsh -V            # version
xonsh --rc          # list rc files
```

## Common Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `SyntaxError` in `.xonshrc` | Plain shell syntax where Python expected | Use `$[cmd]` for subprocesses |
| Commands run as Python | Ambiguous parsing | Prefix with `![]` or use `$[]` |
| Slow startup | Too many `execx` calls or imports | Lazy-load heavy tools |
| Nix env vars missing | `$UPDATE_OS_ENVIRON = False` | Set it `True` in `.xonshrc` |
| Nested xonsh shells | `exec` missing or PPID check wrong | Verify bash auto-exec logic |
| Prompt not updating | `$PROMPT` set after tool init | Set prompt after loading starship |

## Xonsh vs Bash Interop

```python
# Run bash code
bash -c "echo $BASH_VERSION"

# Source bash file
source-bash ~/.bash_aliases

# Capture bash output in Python
result = $(bash -c "compgen -c | head -5").splitlines()

# Run Python from bash (the other way)
$ python -c "import xonsh; print(xonsh.__version__)"
```

## Project-Specific Notes (abode)

- Xonsh is managed via `home.file.".xonshrc"` in `programs/shells.nix`
- There is no `programs.xonsh` in Home Manager — use raw `home.file`
- The xonsh package is explicitly added to `home.packages` in `programs/shells.nix`
- Bash auto-exec lives in `programs.bash.initExtra`

## External References

- `xonsh --help` — CLI options
- `xonsh -c "help()"` — built-in help
- https://xon.sh — official docs
- https://xon.sh/tutorial.html — tutorial
- https://xon.sh/api — API reference
- https://github.com/xonsh/xonsh — source code
