# agent-sandbox

A Docker image running [Claude Code](https://claude.ai/code) and [Codex](https://github.com/openai/codex) on Ubuntu 24.04 LTS, with Docker CLI and GitHub CLI included.

## Build

```bash
./build.sh
```

This passes one build arg:
- `USER_UID` — your host UID, so `agent` can read/write mounted files without `sudo`

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
| Claude Code config | `./storage/.claude` | `/home/agent/.claude` | persistent |
| Codex config | `./storage/.codex` | `/home/agent/.codex` | persistent |
| Git config | `./storage/.gitconfig` | `/home/agent/.gitconfig` | read/write |

## Authentication

On first run, log in to each tool as needed — credentials are persisted via the mounts above so you only need to do this once:

- **Claude Code**: run `claude` and follow the browser prompts, or set `ANTHROPIC_API_KEY`
- **Codex**: set `OPENAI_API_KEY`
- **GitHub CLI**: run `gh auth login`

## Yolo aliases

The image ships two convenience aliases for autonomous operation:

```bash
ccy           # claude --dangerously-skip-permissions
cx-yolo       # codex --dangerously-bypass-approvals-and-sandbox
```

Container instructions are baked into `/etc/claude-code/CLAUDE.md` (Linux managed policy path), which Claude Code auto-loads at conversation start.

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
| GitHub CLI (`gh`) | GitHub apt repo |
| ripgrep | apt |
| Common dev tools | apt (`build-essential`, `jq`, `vim`, `nano`, `make`, `wget`, `zip/unzip`) |

## Accessing host services from the container

`--network=host` does not work on Docker Desktop for Mac. Use `host.docker.internal` instead — Docker Desktop automatically resolves this to the Mac host's IP from inside any container:

```bash
# e.g. a Postgres running on the Mac host
psql -h host.docker.internal -p 5432

# e.g. a local web server
curl http://host.docker.internal:8080
```

This works for any service running on the host without any extra flags in `run.sh`.

## Adding Docker CLI access

Docker is not installed by default. To enable the agent to run `docker` commands:

**1. Add Docker CLI to the image** — in [Dockerfile](Dockerfile), after the GitHub CLI block:

```dockerfile
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
       https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*
```

Also add the docker group to the user creation step:

```dockerfile
ARG DOCKER_GID=999
RUN groupadd -f -g ${DOCKER_GID} docker \
    && useradd -m -s /bin/bash -u ${USER_UID} agent \
    && usermod -aG docker,sudo agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/agent
```

**2. Pass `DOCKER_GID` at build time** — in [build.sh](build.sh):

```bash
if [[ "$(uname)" == "Darwin" ]]; then
  DOCKER_GID=$(stat -f "%g" /var/run/docker.sock)
else
  DOCKER_GID=$(stat -c "%g" /var/run/docker.sock)
fi

docker build \
  --build-arg USER_UID=$(id -u) \
  --build-arg DOCKER_GID="$DOCKER_GID" \
  -t agent-sandbox \
  .
```

**3. Mount the socket and add GID 0 at runtime** — in [run.sh](run.sh):

```bash
-v /var/run/docker.sock:/var/run/docker.sock \
--group-add 0 \      # Docker Desktop for Mac: socket is GID 0 inside container
--group-add docker \ # Linux: matches the DOCKER_GID baked into the image
```

> On Docker Desktop for Mac the socket always appears as GID 0 inside the container, regardless of `DOCKER_GID`. The `--group-add 0` handles this at runtime.

## Notes

- The container runs as a non-root user (`agent`) with passwordless `sudo`.
