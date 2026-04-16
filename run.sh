#!/bin/bash
# Usage: ./run.sh [path/to/workdir]
# If no argument given, mounts the current directory.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STORAGE_DIR="$SCRIPT_DIR/storage"

# At least one working directory is required
if [ $# -eq 0 ]; then
  echo "Usage: ./run.sh <workdir> [workdir2 ...]"
  exit 1
fi

# Ensure persistent storage directories exist
mkdir -p "$STORAGE_DIR/.claude"
mkdir -p "$STORAGE_DIR/.codex"
touch "$STORAGE_DIR/.gitconfig"

# Build volume mounts for all provided directories
WORKDIR_MOUNTS=()
for dir in "$@"; do
  abs=$(cd "$dir" && pwd)
  WORKDIR_MOUNTS+=(-v "${abs}:${abs}")
done

# First directory becomes the container's working directory
PRIMARY_WORKDIR=$(cd "$1" && pwd)

docker run -itd \
  --name agent-sandbox \
  --hostname sandbox \
  \
  `# Docker daemon access` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add 0 \
  --group-add docker \
  \
  `# Working directories mounted at the same paths as on the host` \
  "${WORKDIR_MOUNTS[@]}" \
  -w "${PRIMARY_WORKDIR}" \
  \
  `# Persistent config for Claude Code and Codex` \
  -v "$STORAGE_DIR/.claude:/home/agent/.claude" \
  -v "$STORAGE_DIR/.codex:/home/agent/.codex" \
  \
  `# Git identity` \
  -v "$STORAGE_DIR/.gitconfig:/home/agent/.gitconfig" \
  \
  ghcr.io/foralan/agent-sandbox:latest
