# agent-sandbox

A Docker image running [Claude Code](https://claude.ai/code) and [Codex](https://github.com/openai/codex) on Ubuntu 24.04 LTS, with Docker CLI and GitHub CLI included.

## Build

```bash
./build.sh
```

This passes two args into the image:
- `USER_UID` — your host UID, so `agent` can read/write mounted files without `sudo`
- `DOCKER_GID` — your host Docker socket GID, so `agent` can run `docker` without `sudo`

## Run

Use the provided script:

```bash
# Mount a single directory (becomes the working directory)
./run.sh ~/projects/my-app

# Mount multiple directories (first is the working directory)
./run.sh ~/projects/my-app ~/projects/shared-lib
```

The script mounts:

| Mount | Host path | Container path | Notes |
|---|---|---|---|
| Working directories | each arg | same path as host | read/write, first is `-w` |
| Docker socket | `/var/run/docker.sock` | `/var/run/docker.sock` | for Docker access |
| Claude Code config | `./storage/.claude` | `/home/agent/.claude` | persistent |
| Codex config | `./storage/.codex` | `/home/agent/.codex` | persistent |
| Git config | `./storage/.gitconfig` | `/home/agent/.gitconfig` | read/write |

## Authentication

On first run, log in to each tool as needed — credentials are persisted via the mounts above so you only need to do this once:

- **Claude Code**: run `claude` and follow the browser prompts, or set `ANTHROPIC_API_KEY`
- **Codex**: set `OPENAI_API_KEY`
- **GitHub CLI**: run `gh auth login`

## Git identity

Your `~/.gitconfig` is mounted read-only, so Git identity carries over automatically from the host. If you don't have one set on the host:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## What's installed

| Tool | Install method |
|---|---|
| Node.js 22 LTS | NodeSource |
| Claude Code | Official shell script (auto-updates) |
| Codex CLI | npm |
| uv | Official shell script |
| Docker CLI | Docker apt repo |
| GitHub CLI (`gh`) | GitHub apt repo |
| ripgrep | apt |
| Common dev tools | apt (`build-essential`, `jq`, `vim`, `nano`, `make`, `wget`, `zip/unzip`) |

## Notes

- The container runs as a non-root user (`agent`) with passwordless `sudo`.
- Only the Docker **CLI** is installed — it uses the host Docker daemon via the mounted socket.
