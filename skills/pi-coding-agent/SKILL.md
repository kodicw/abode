---
name: pi-coding-agent
description: Comprehensive guide for the pi coding agent. Covers extensions, events, custom tools, UI components, commands, state management, and integration patterns. Use when building pi extensions, writing custom tools, or understanding the pi lifecycle and API.
---

# Pi Coding Agent Guide

## What is pi?

Pi is a coding agent harness — an LLM-driven terminal tool for reading files, executing commands, editing code, and writing new files. It is extensible via TypeScript extensions and supports custom tools, events, UI components, and commands.

- Runs in interactive TUI, RPC, JSON, and print modes
- Supports multiple model providers (Anthropic, OpenAI, local, custom)
- Auto-discovers skills, extensions, prompts, and themes
- Built-in tools: read, bash, write, edit, grep, find, ls

## Quick Reference

```bash
pi                          # Interactive mode
pi -p "prompt"              # Print mode (one-shot)
pi --mode json              # JSON event stream
pi --mode rpc               # RPC server mode
pi -e ./ext.ts              # Load extension
pi --no-builtin-tools       # Disable built-in tools
pi --no-skills              # Disable skill discovery

# Built-in commands
/new                        # New session
/resume                     # Resume session
/fork                       # Fork from entry
/clone                      # Clone entry
/compact                    # Compact session
/tree                       # Navigate tree
/model                      # Switch model
/reload                     # Reload extensions/skills
/settings                   # Open settings
```

## Extension Basics

### Structure

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Subscribe to events
  pi.on("session_start", async (event, ctx) => {
    ctx.ui.notify("Loaded!", "info");
  });

  // Register custom tool
  pi.registerTool({ ... });

  // Register command
  pi.registerCommand("hello", {
    description: "Say hello",
    handler: async (args, ctx) => {
      ctx.ui.notify(`Hello ''${args || "world"}!`, "info");
    },
  });
}
```

### Extension Locations

| Location | Scope |
|----------|-------|
| `~/.pi/agent/extensions/*.ts` | Global (all projects) |
| `~/.pi/agent/extensions/*/index.ts` | Global (subdirectory) |
| `.pi/extensions/*.ts` | Project-local |
| `.pi/extensions/*/index.ts` | Project-local (subdirectory) |

Load with `--extension ./path.ts` for quick tests. Auto-discovered extensions hot-reload with `/reload`.

### Package Structure (with deps)

```
my-extension/
├── package.json          # Declares deps and pi.extensions entry
├── package-lock.json
├── node_modules/         # After npm install
└── src/
    └── index.ts
```

```json
{
  "name": "my-extension",
  "dependencies": { "zod": "^3.0.0" },
  "pi": { "extensions": ["./src/index.ts"] }
}
```

## Events

### Lifecycle Overview

```
pi starts
  ├─► session_start { reason: "startup" }
  └─► resources_discover { reason: "startup" }
      │
      ▼
user sends prompt
  ├─► input (can intercept/transform)
  ├─► before_agent_start (inject message, modify system prompt)
  ├─► agent_start
  │   ┌─── turn (repeats while LLM calls tools) ───┐
  │   │                                            │
  │   ├─► turn_start                               │
  │   ├─► context (modify messages)                │
  │   ├─► before_provider_request                  │
  │   ├─► after_provider_response                  │
  │   │     LLM responds, may call tools:          │
  │   │     ├─► tool_execution_start               │
  │   │     ├─► tool_call (can block)              │
  │   │     ├─► tool_execution_update              │
  │   │     ├─► tool_result (can modify)           │
  │   │     └─► tool_execution_end                 │
  │   │                                            │
  │   └─► turn_end                                 │
  │                                                │
  └─► agent_end                                    │
```

### Key Events

| Event | When | Can... |
|-------|------|--------|
| `session_start` | Session created/resumed | Notify, init state |
| `session_shutdown` | Before teardown | Cleanup, save state |
| `before_agent_start` | Before agent loop | Inject message, modify system prompt |
| `turn_start` / `turn_end` | Each LLM turn | Track turn state |
| `tool_call` | Before tool executes | **Block** or mutate args |
| `tool_result` | After tool finishes | Modify result |
| `input` | User input received | Transform or handle without LLM |
| `model_select` | Model changes | Update UI state |

> **Blocking examples:** See the [Permission Gate](#permission-gate) and [Input Transform](#input-transform) examples under [Common Patterns](#common-patterns).

## Custom Tools

```typescript
import { Type } from "typebox";
import { StringEnum } from "@earendil-works/pi-ai";

pi.registerTool({
  name: "greet",
  label: "Greet",
  description: "Greet someone by name",
  promptSnippet: "Greet users by name",
  promptGuidelines: ["Use greet when the user says hello."],
  parameters: Type.Object({
    name: Type.String({ description: "Name to greet" }),
  }),
  async execute(toolCallId, params, signal, onUpdate, ctx) {
    onUpdate?.({ content: [{ type: "text", text: "Working..." }] });
    return {
      content: [{ type: "text", text: `Hello, ''${params.name}!` }],
      details: {},
    };
  },
});
```

### Tool Tips

- Use `StringEnum` for string enums (not Type.Union/Type.Literal)
- Throw errors to signal `isError: true` to the LLM
- Return `terminate: true` to skip follow-up LLM call
- Use `promptSnippet` for one-line tool listing in system prompt
- Use `promptGuidelines` for tool-specific guidance (name the tool explicitly)
- Use `withFileMutationQueue()` for file-mutating tools to prevent races
- Truncate output: `truncateHead()` / `truncateTail()` (50KB / 2000 lines limit)

## UI Methods (ctx.ui)

### Dialogs

```typescript
const choice = await ctx.ui.select("Pick one:", ["A", "B", "C"]);
const ok = await ctx.ui.confirm("Delete?", "This cannot be undone");
const name = await ctx.ui.input("Name:", "placeholder");
const text = await ctx.ui.editor("Edit:", "prefilled text");
ctx.ui.notify("Done!", "info");  // non-blocking
```

### Timed Dialogs

```typescript
const confirmed = await ctx.ui.confirm(
  "Timed Confirmation",
  "Auto-cancels in 5s",
  { timeout: 5000 }
);
// or with abort controller for manual timeout/cancel detection
```

### Status & Widgets

```typescript
ctx.ui.setStatus("my-ext", "Processing...");
ctx.ui.setStatus("my-ext", undefined);  // clear

ctx.ui.setWidget("my-widget", ["Line 1", "Line 2"]);
ctx.ui.setWidget("my-widget", undefined);  // clear

ctx.ui.setWorkingMessage("Thinking deeply...");
ctx.ui.setWorkingVisible(false);  // hide loader
ctx.ui.setWorkingIndicator({
  frames: [ctx.ui.theme.fg("accent", "●")],
});

ctx.ui.setTitle("pi - my-project");
ctx.ui.setFooter((tui, theme) => ({
  render(width) { return [theme.fg("dim", "Custom footer")]; },
  invalidate() {},
}));
```

### Custom Components

```typescript
import { Text } from "@earendil-works/pi-tui";

const result = await ctx.ui.custom<boolean>((tui, theme, keybindings, done) => {
  const text = new Text("Press Enter to confirm, Escape to cancel", 1, 1);
  text.onKey = (key) => {
    if (key === "return") done(true);
    if (key === "escape") done(false);
    return true;
  };
  return text;
});
```

### Overlay Mode (Experimental)

```typescript
const result = await ctx.ui.custom<string>(
  (tui, theme, keybindings, done) => new MyOverlay({ onClose: done }),
  { overlay: true, overlayOptions: { anchor: "top-right", width: "50%" } }
);
```

## Session Management

### State Persistence

```typescript
// Save state
pi.appendEntry("my-state", { count: 42 });

// Restore on session start
pi.on("session_start", async (_event, ctx) => {
  for (const entry of ctx.sessionManager.getEntries()) {
    if (entry.type === "custom" && entry.customType === "my-state") {
      // Reconstruct from entry.data
    }
  }
});
```

### Session Navigation

```typescript
// Available in commands (not event handlers):
await ctx.newSession({ parentSession, withSession: async (ctx) => { ... } });
await ctx.fork(entryId, { withSession: async (ctx) => { ... } });
await ctx.navigateTree(targetId, { summarize: true });
await ctx.switchSession(sessionPath, { withSession: async (ctx) => { ... } });
await ctx.reload();
```

### Session Labels

```typescript
pi.setLabel(entryId, "checkpoint-before-refactor");
const label = ctx.sessionManager.getLabel(entryId);
```

## Providers & Models

### Register Custom Provider

```typescript
pi.registerProvider("my-proxy", {
  name: "My Proxy",
  baseUrl: "https://proxy.example.com",
  apiKey: "PROXY_API_KEY",
  api: "anthropic-messages",
  models: [{
    id: "claude-sonnet",
    name: "Claude Sonnet",
    reasoning: false,
    input: ["text", "image"],
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    contextWindow: 200000,
    maxTokens: 16384,
  }],
});
```

### Async Factory for Dynamic Models

```typescript
export default async function (pi: ExtensionAPI) {
  const res = await fetch("http://localhost:1234/v1/models");
  const data = await res.json();
  pi.registerProvider("local-openai", {
    baseUrl: "http://localhost:1234/v1",
    apiKey: "LOCAL_OPENAI_API_KEY",
    api: "openai-completions",
    models: data.data.map((m) => ({
      id: m.id,
      name: m.name ?? m.id,
      reasoning: false,
      input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: m.context_window ?? 128000,
      maxTokens: m.max_tokens ?? 4096,
    })),
  });
}
```

## Common Patterns

### Permission Gate
```typescript
pi.on("tool_call", async (event, ctx) => {
  if (event.toolName === "bash" && event.input.command?.includes("sudo")) {
    const ok = await ctx.ui.confirm("Sudo!", "Allow sudo?");
    if (!ok) return { block: true, reason: "Blocked" };
  }
});
```

### Input Transform
```typescript
pi.on("input", async (event, ctx) => {
  if (event.text.startsWith("?quick ")) {
    return { action: "transform", text: `Respond briefly: ''${event.text.slice(7)}` };
  }
  return { action: "continue" };
});
```

### System Prompt Injection
```typescript
pi.on("before_agent_start", async (event, ctx) => {
  return {
    systemPrompt: event.systemPrompt + "\n\nAlways include unit tests.",
  };
});
```

### Custom Compaction
```typescript
pi.on("session_before_compact", async (event, ctx) => {
  return {
    compaction: {
      summary: "Custom summary...",
      firstKeptEntryId: event.preparation.firstKeptEntryId,
      tokensBefore: event.preparation.tokensBefore,
    }
  };
});
```

### Git Checkpoint on Turns
```typescript
pi.on("turn_start", async (event, ctx) => {
  await pi.exec("git", ["stash", "push", "-m", `turn-''${event.turnIndex}`]);
});
```

## Mode Behavior

| Mode | UI | Notes |
|------|-----|-------|
| Interactive | Full TUI | Normal operation |
| RPC | JSON protocol | Host handles UI |
| JSON | No-op | Event stream to stdout |
| Print (-p) | No-op | Extensions run but can't prompt |

Always check `ctx.hasUI` before using UI methods in extensions meant for non-interactive modes.

## Pitfalls

| Issue | Solution |
|-------|----------|
| `Type.Union` enums fail | Use `StringEnum` from `@earendil-works/pi-ai` |
| Extension state lost on reload | Store in session via `appendEntry` |
| Old session state conflicts | Use `prepareArguments` for schema migration |
| File mutations race | Use `withFileMutationQueue()` |
| Stale context after session replace | Use only replacement-session `ctx` in `withSession` |
| Tool output too large | Use `truncateHead` / `truncateTail` |
| Custom tool not in prompt | Add `promptSnippet` |

## External References

- `pi --help` — CLI options
- `pi --list-models` — available models
- `/reload` — hot-reload extensions
- https://pi.dev — documentation
- https://github.com/earendil-dev/pi-coding-agent — source & examples
- `tui.md` — full TUI component API
- `keybindings.md` — shortcut reference
- `themes.md` — theme creation
- `skills.md` — skill format (this format)
- `custom-provider.md` — advanced provider setup
- `examples/extensions/` — working code examples
