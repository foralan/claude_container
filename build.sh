#!/bin/bash
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "dev")

docker build \
  --build-arg USER_UID=$(id -u) \
  -t agent-sandbox:${VERSION} \
  -t agent-sandbox:latest \
  .
