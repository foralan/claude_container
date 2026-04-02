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

### Why `.linux_venv` instead of `.venv`

Projects mounted from the Mac host may already contain a `.venv` directory — built for macOS (darwin/arm64 or darwin/x86_64). Those binaries are **incompatible** with this Linux container and must not be used.

Key rules:
- **Never activate or use `.venv`** — it may exist but is built for macOS.
- **Always use `.linux_venv`** for any Python work inside the container.
- If a tool or script hardcodes `.venv` (e.g. `source .venv/bin/activate`), replace or override with `.linux_venv`.
- When checking whether a venv is healthy, verify the platform: `python -c "import platform; print(platform.system())"` should print `Linux`.
- `uv sync`, `uv run`, and `uv pip` all respect `UV_PROJECT_ENVIRONMENT` automatically — prefer them over manual venv activation.

## draw.io Export

draw.io Desktop is installed and can export `.drawio` files from the terminal. It requires a virtual X display — `--headless` alone is not sufficient in this container.

**Always use `xvfb-run`:**

```bash
# Export to PNG
xvfb-run -a drawio --no-sandbox -x -f png your-file.drawio

# Export to PNG and embed the original diagram XML
xvfb-run -a drawio --no-sandbox -x -f png -e your-file.drawio
```

Key rules:
- Do **not** pass extra Chromium flags (e.g. `--disable-gpu`) — the CLI parser may treat them as the input path and fail with `Error: input file/directory not found`.
- `drawio-mcp`'s `mcp-tool-server` does **not** export to PNG; it only opens/loads diagrams in the editor. Use the Desktop CLI above for image export.
- `xvfb-run` and `Xvfb` are already installed at `/usr/bin/`.
