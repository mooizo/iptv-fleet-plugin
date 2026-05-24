# Tool Scripts Reference

The Python tools that power each pipeline step live in the **source repo** (`/Users/boullamjaouad/Desktop/Website Planning Iptv/tools/`), not inside this skill. This README is a pointer so Claude knows what exists without having to re-discover it.

To use the tools in a new IPTV project, either:
1. Clone or symlink the source repo alongside the new project, or
2. Copy the specific tools you need (they're mostly self-contained, sharing only `_lib/`)

## Tool inventory

| Tool | Step | Purpose |
|---|---|---|
| `dataforseo_keyword_research.py` | 01 | DataForSEO Labs: seed expansion, SERPs, volume/difficulty, related keywords |
| `competitor_scan.py` | 02 | Hybrid Firecrawl + Perplexity + Claude teardown of top 5 |
| `intent_cluster.py` | 03 | Cluster keywords into page_map.json (fuzzy dedupe via RapidFuzz) |
| `blog_topic_research.py` | 03b | Perplexity discovery + Claude clustering for blog backlog |
| `write_content.py` | 04 | Spawn Claude Sonnet 4.6 as `iptv-seo-writer`; emit all markdown |
| `content_linter.py` | 04 QA | Frontmatter validation, banned phrase check, currency format, lang purity |
| `lang_detect.py` | 04 QA | lingua-language-detector wrapper |
| `nanobana_generate.py` | 06 | Google Gemini 2.5 Flash Image — single-image generation |
| `generate_all_images.py` | 06 | Batch wrapper for the 15-image manifest |
| `a11y_check.py` | 07 | Playwright + axe-core accessibility audit on dist/ |
| `link_check.py` | 07 | Static link checker for dist/ (also supports crawl mode) |
| `pagespeed.py` | 07 | Google PageSpeed Insights wrapper (mobile + desktop) |
| `schema_validate.py` | 07 | JSON-LD schema.org validation |
| `generate_report.py` | any | Render .tmp/{country}_{lang}/* as HTML dashboard |
| `check_indexed.py` | 08 | Google Search Console URL Inspection (post-deploy) |

## Shared library (`tools/_lib/`)

- `env.py` — loads `.env`, validates required keys
- `paths.py` — standardizes `.tmp/{country}_{lang}/` directory structure
- `budget.py` — per-API daily cost tracking (aborts call if cap exceeded)
- `http.py` — auth-aware HTTP client (BasicAuth for DataForSEO, Bearer for others)
- `logging.py` — structured logs
- `cli.py` — argparse boilerplate (every tool takes `--country` and `--language`)
- `locale.py` — currency/date formatting per country

## Common invocation patterns

```bash
# Step 01 — keyword research
python tools/dataforseo_keyword_research.py --country DE --language de --brand "IPTV Klar"

# Step 02 — competitor scan
python tools/competitor_scan.py --country DE --language de

# Step 02 fallback — no Perplexity
python tools/competitor_scan.py --country DE --language de --skip-perplexity

# Step 04 — content writer
python tools/write_content.py --country DE --language de --brand "IPTV Klar" --domain iptvklar.de

# Step 04 QA
python tools/content_linter.py --country DE --language de

# Step 06 — image generation
python tools/generate_all_images.py --country DE --language de --brand "IPTV Klar"

# Step 07 — audit
python tools/a11y_check.py --dist ./dist
python tools/link_check.py --dist ./dist
python tools/pagespeed.py --url https://iptvklar.de --strategy mobile
python tools/schema_validate.py --dist ./dist

# Pipeline status dashboard
python tools/generate_report.py --country DE --language de --open
```

## Why tools aren't copied into this skill

1. **They evolve** — every build teaches new lessons (see `competitor-scan-gotchas.md`). Keeping tools in one canonical location means fixes propagate automatically.
2. **Shared state** — `_lib/budget.py` writes daily spend tracking to `~/.cache/wat-budget/`. Multiple copies would fragment the tracking.
3. **Secrets** — tools read `.env` relative to the script, not the working directory. Copying them into each project would require per-project `.env` duplication.

**Rule of thumb:** this skill gives you the *decisions* (references, assets, SKILL.md). The source repo gives you the *execution* (tools, workflows). Keep them linked — don't try to make the skill self-sufficient for tool execution.
