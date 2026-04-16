#!/bin/bash
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "dev")

if [[ "$(uname)" == "Darwin" ]]; then
  DOCKER_GID=$(stat -f "%g" /var/run/docker.sock 2>/dev/null || echo 0)
else
  DOCKER_GID=$(stat -c "%g" /var/run/docker.sock 2>/dev/null || echo 0)
fi

docker build \
  --build-arg USER_UID=$(id -u) \
  --build-arg DOCKER_GID="$DOCKER_GID" \
  -t agent-sandbox:${VERSION} \
  -t agent-sandbox:latest \
  .
