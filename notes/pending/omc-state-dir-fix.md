# OMC State Directory Centralization

## Problem

oh-my-claudecode (OMC) creates a `.omc/` directory in every project's working directory, cluttering repos and requiring `.gitignore` entries.

## Goal

Centralize all `.omc` state into a single location (`/home/agent/.claude/.omc/`) using the `OMC_STATE_DIR` environment variable, so `.omc/` is never created in project directories.

## Changes Made

### 1. Set `OMC_STATE_DIR` in Claude Code settings.json

**File:** `~/.claude/settings.json`

Added to the `env` section:

```json
"OMC_STATE_DIR": "/home/agent/.claude/.omc"
```

**Important:** Must use an absolute path, not `~`. Node.js does not expand `~` in `process.env`, so `~/.claude/.omc` would be treated as a literal relative path.

### 2. Fixed bug in OMC HUD stdin cache

**File:** `~/.claude/plugins/cache/omc/oh-my-claudecode/4.11.3/dist/hud/stdin.js`

The HUD stdin cache was hardcoding `join(root, '.omc', 'state', 'hud-stdin-cache.json')` instead of using `getOmcRoot()`, which respects `OMC_STATE_DIR`. This caused a local `.omc/` to be created even when `OMC_STATE_DIR` was set.

**Fix:** Changed `getStdinCachePath()` and `writeStdinCache()` to use `getOmcRoot()`:

```js
// Before (broken)
const root = getWorktreeRoot() || process.cwd();
return join(root, '.omc', 'state', 'hud-stdin-cache.json');

// After (fixed)
return join(getOmcRoot(), 'state', 'hud-stdin-cache.json');
```

Also added `getOmcRoot` to the import from `worktree-paths.js`.

**Note:** This fix is in the plugin cache and will be overwritten on OMC update. Should be reported upstream to [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode).

### 3. Removed `.omc/` from project `.gitignore`

The `.omc/` entry in `llm_go/.gitignore` was removed since `.omc/` should no longer be created in project directories.

## How It Works

With `OMC_STATE_DIR` set, OMC stores per-project state at:

```
/home/agent/.claude/.omc/{project-name}-{hash}/
```

The project identifier is derived from the git remote URL (SHA-256 hash, first 16 chars), so state is stable across worktrees and clones. The directory structure inside is the same as the local `.omc/`:

```
/home/agent/.claude/.omc/llm_go-a26973a3fe37acd0/
  state/sessions/
  plans/
  research/
  logs/
  skills/
  notepad.md
  project-memory.json
```

## Approaches That Don't Work

| Approach | Why it fails |
|----------|-------------|
| `~/.claude/.omc` in settings.json | Node.js doesn't expand `~` |
| `.bashrc` export | Only sourced for interactive shells, not by Claude Code's Node.js process |
| `.zshrc` on macOS | Works for local macOS, but not for the Linux container environment |

## Date

2026-04-10
