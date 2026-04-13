# Claude Container

A Docker sandbox image for running AI coding agents (Claude Code, Codex) on Ubuntu 24.04.

## Key files

- `Dockerfile` — image definition
- `build.sh` — builds the image, tags with git version
- `run.sh` — runs the container with persistent config and working directory mounts
- `container-instructions.md` — baked into the image as `/etc/claude-code/CLAUDE.md` (managed policy); auto-loaded by Claude Code on Linux, symlinked to `~/AGENTS.md` for Codex

## How versioning works

`build.sh` tags the image with the current git tag (`git describe --tags`). Tag a new release with `git tag vX.Y` before building.

## Adding Docker CLI support

Docker CLI is not installed by default. See the "Adding Docker CLI access" section in README.md for step-by-step instructions to re-enable it.
