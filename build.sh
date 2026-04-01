#!/bin/bash
docker build \
  --build-arg USER_UID=$(id -u) \
  --build-arg DOCKER_GID=$(stat -f "%g" /var/run/docker.sock) \
  -t agent-sandbox \
  .
