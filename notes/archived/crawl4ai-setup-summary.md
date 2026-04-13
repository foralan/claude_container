# Crawl4AI Container Setup Summary

## Installed Components

| Component | Version | Install Method |
|-----------|---------|----------------|
| Python | 3.12.3 | Pre-installed |
| pip3 | 24.0 | apt |
| python3-venv | 3.12.3 | apt |
| pipx | 1.4.3 | apt |
| crawl4ai | 0.8.6 | pipx |
| Playwright Chromium | v1208 (Chrome 145) | crawl4ai-setup |

## CLI Tools Available

| Command | Purpose |
|---------|---------|
| `crwl crawl <url>` | Crawl a URL from the terminal |
| `crawl4ai-doctor` | Health check / verify installation |
| `crawl4ai-setup` | Post-install setup (Playwright browsers) |
| `crawl4ai-download-models` | Download optional AI models |
| `crawl4ai-migrate` | Database migration tool |

## crwl CLI Key Options

```bash
crwl crawl https://example.com                          # Basic crawl
crwl crawl https://example.com -o markdown              # Output as markdown
crwl crawl https://example.com -o json                  # Output as JSON
crwl crawl https://example.com -q "what is this about?" # Ask a question
crwl crawl https://example.com -j "extract products"    # LLM extraction
crwl crawl https://example.com -s schema.json           # Schema-based extraction
crwl crawl https://example.com --deep-crawl bfs --max-pages 50  # Deep crawl
crwl crawl https://example.com -O output.md             # Save to file
crwl crawl https://example.com --bypass-cache           # Skip cache
```

## Installed Skill

The `crawl4ai` skill is installed at `~/.claude/skills/crawl4ai/` and includes:

- `SKILL.md` — Full usage reference (Python API patterns)
- `references/complete-sdk-reference.md` — Complete SDK docs (23K words)
- `scripts/basic_crawler.py` — Simple markdown extraction
- `scripts/batch_crawler.py` — Multi-URL concurrent processing
- `scripts/extraction_pipeline.py` — Schema generation + data extraction
- `tests/` — Test suite for all major features

## Paths

| Item | Path |
|------|------|
| pipx venv | `~/.local/share/pipx/venvs/crawl4ai/` |
| Playwright browsers | `~/.cache/ms-playwright/` |
| Crawl4AI database | `~/.crawl4ai/crawl4ai.db` |
| Skill files | `~/.claude/skills/crawl4ai/` |

## Health Check

```
crawl4ai-doctor → ✅ Crawling test passed!
```
