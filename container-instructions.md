# Agent Container Instructions

## Environment

You are running inside a Docker container (Ubuntu 24.04) on a Mac host via Docker Desktop.

## Network

The container uses **bridge mode** networking. Do not use `localhost` to reach services on the host machine — it will only resolve to the container itself.

To reach a service running on the Mac host, use:
```
host.docker.internal:<port>
```

Examples:
- PostgreSQL on the host: `host.docker.internal:5432`
- A local web server: `host.docker.internal:8080`

This works for any port without any extra configuration.

## Python Virtual Environments

The environment variable `UV_PROJECT_ENVIRONMENT=.linux_venv` is set in this container.

When using `uv`, virtual environments are created in `.linux_venv` instead of the default `.venv`. Always use `.linux_venv` when referencing or activating the virtual environment:

```bash
source .linux_venv/bin/activate
```

This naming avoids conflicts with `.venv` directories created on the Mac host (which contain Mac binaries incompatible with this Linux container).
