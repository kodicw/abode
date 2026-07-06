# abode

Home Manager flake for ChromeOS/Crostini (Nix-on-Chromebook).

## Apply

```sh
home-manager switch --flake .#<user>
home-manager build --flake .#<user>   # dry-run
nix flake update                       # bump all inputs
```

5 profiles: `kodicw`, `charles`, `nixos`, `kodiwalls` (x86_64); `droid` (aarch64).
User configs are `config/users/<name>.nix` — simple 3-field attrsets (`username`, `homeDirectory`, `stateVersion`). Add a new user by creating that file and adding a `homeConfigurations` entry in `flake.nix`.

## Module layout

`self.homeManagerModules.default` bundles:

| Module | File |
|--------|------|
| config-home | `config/home.nix` |
| packages | `packages.nix` |
| programs-devtools | `programs/devtools.nix` |
| programs-shells | `programs/shells.nix` |
| programs-terminals | `programs/terminals.nix` |
| programs-ai | `programs/ai.nix` |
| session | `session.nix` |

Explicit-import-only (not in default): `activation-crostini-icons` (`activation/crostini-icons.nix`), `programs/csharp.nix`, `systemd/opencode-server.nix`, `systemd/rclone-gdrive.nix`.

## Quirks

- **Primary shell is Bash.** Nushell and Xonsh are also installed and available. Edit configs in `programs/shells.nix`.
- **Wayland session vars** in `session.nix` are set on x86_64 only (not aarch64/droid).
- **Crostini activation** skips `.desktop` files that already exist and don't reference `nixGLIntel` — prevents duplicate launcher entries.
- **`.gitignore`** only ignores `result`. No CI, no tests, no linters.
- **External flake**: `github:kodicw/polarbear` provides `nixvim` and `tools-ssh` packages.
- **`config/home.nix`** expects a `userModule` arg passed via `extraSpecialArgs` in `flake.nix`.
- **Recent commits** by "JBot (dev)" — an AI agent, not the human.
- **Herdr execution constraint**: When running inside the herdr multiplexer (e.g. when `HERDR_ENV=1` is set or herdr CLI is available), always execute terminal commands in a separate herdr pane (e.g. via `herdr pane run <pane> "<command>"`) instead of executing commands directly in the background or blocking the active agent's pane.

## Context-mode hierarchy

To keep conversation context small, use the context-mode tool chain in this precedence order:

1. **`ctx_batch_execute`** — Run multiple commands in one call. Every command's output is auto-indexed into the knowledge base for later `ctx_search`. Best for: multi-issue lookups, git log + git diff + git blame, multi-file reads, gathering data then querying it.
2. **`ctx_execute`** — Run code in a sandboxed subprocess. Only what you `console.log()` enters conversation memory. Best for: filtering, aggregating, parsing logs or JSON, scanning many source files without reading them all.
3. **`ctx_execute_file`** — Read a file into a sandbox and run code over it. Only the derived answer enters context. Best for: analyzing one large structured file (CSV, JSON, log).
4. **`ctx_search`** — Search the unified knowledge base (indexed content + auto-captured session memory). Best for: recalling previously indexed docs, prior decisions, error resolutions.

Only fall through to direct `read`/`bash` when the output is short and you will consume it all verbatim.

## Skills ecosystem

The open agent skills ecosystem at [skills.sh](https://skills.sh/) provides modular packages that extend agent capabilities.

### Discover skills
```bash
npx skills find <query> [--owner <owner>]
```

### Install a skill
```bash
npx skills add <owner/repo@skill> -g -y
```

### Check for updates
```bash
npx skills check
npx skills update
```

### Built-in skills (no install needed)

| Skill | Purpose |
|-------|---------|
| `context-mode` | Sandbox execution, indexing, BM25 search — prevents context bloat |
| `pi-subagents` | Subagent delegation: chain, parallel, async, intercom |
| `herdr-pi` | herdr pane/workspace/tab control tools |
| `swarm` | Quorum consensus and scoped locks for subagents |
| `actors` | Actor lifecycle (`spawn`, `message`, `inspect`) |
| `pi-coding-agent` | Build pi extensions, custom tools, themes, events |
| `home-manager-guide` | Home Manager setup, flakes, program modules, secrets |
| `nix-nixos-guide` | Nix syntax, flakes, NixOS — tailored for `abode` |
| `opentofu-guide` | OpenTofu/Terraform IaC |
| `gh-cli` | GitHub CLI — repos, issues, PRs, Actions |
| `justfile-guide` | Just command runner syntax and recipes |
| `xonsh-guide` | Xonsh Python-powered shell |
| `agy` | Antigravity CLI — fast, lightweight coding agent |
| `codex` | Codex CLI — powerful, deep-reasoning coding agent |
| `librarian` | Research open-source libraries with GitHub permalinks |

### Recommended installs from the open ecosystem

| Skill | Installs | Install command |
|-------|----------|----------------|
| `wshobson/agents@git-advanced-workflows` | 14.6K | `npx skills add wshobson/agents@git-advanced-workflows -g -y` |
| `addyosmani/agent-skills@git-workflow-and-versioning` | 6.9K | `npx skills add addyosmani/agent-skills@git-workflow-and-versioning -g -y` |
| `ailabs-393/ai-labs-claude-skills@docker-containerization` | 905 | `npx skills add ailabs-393/ai-labs-claude-skills@docker-containerization -g -y` |
| `0xbigboss/claude-code@nix-best-practices` | 419 | `npx skills add 0xbigboss/claude-code@nix-best-practices -g -y` |
| `affaan-m/everything-claude-code@security-review` | 11.2K | `npx skills add affaan-m/everything-claude-code@security-review -g -y` |
| `marcfargas/odoo-toolbox@odoo` | 142 | `npx skills add marcfargas/odoo-toolbox@odoo -g -y` |

