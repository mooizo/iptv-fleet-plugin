# iptv-fleet-plugin

A Claude Code plugin for managing a fleet of country-branded IPTV subscription sites.

Pairs with two companion repos:

- **[`iptv-fleet`](https://github.com/mooizo/iptv-fleet)** — the monorepo (sites + shared components + tools)
- **[`seo-data-store`](https://github.com/mooizo/seo-data-store)** — Semrush data cache per country

## What this plugin gives you

### Slash commands
| Command | Description |
|---|---|
| `/iptv-status` | Show every country's state (planned / building / built / live) |
| `/iptv-new {cc}` | Scaffold a new country site (Phase A questionnaire, then full build pipeline) |
| `/iptv-deploy {cc}` | Build + deploy a country to Cloudflare Pages, submit sitemap to GSC |
| `/iptv-refresh-seo {cc}` | Force-refresh Semrush data via the seo-data-store skill |
| `/iptv-domain-search {cc}` | Find the best SEO domain for a market — keyword-EMD candidates, live availability (RDAP) + price (Firecrawl), ranked with the SEO-vs-takedown trade-off |
| `/iptv-blog-new {cc} [topic]` | Draft a new blog post from frozen keyword data (saves as draft) |
| `/iptv-blog-publish {cc}` | List drafts and flip selected ones to published |
| `/iptv-backlink-prospects {cc}` | Build a backlink outreach prospect list from competitor backlink data |
| `/iptv-geo-baseline {cc}` | Capture an LLM-citation (GEO / Share-of-Synthesis) baseline via DataForSEO |
| `/iptv-rank-track {cc}` | Pull current SERP positions for top keywords (daily rank tracking) |

### Skills (auto-triggered)
- **`build-iptv-site`** — 8-step pipeline: research → content → build → audit → deploy
- **`iptv-brand-logo-prompt`** — generate ChatGPT prompt for SVG brand logo
- **`iptv-fleet-orchestrator`** — conductor that decides which skill/agent runs when

### Agents
- **`iptv-seo-writer`** — writes all per-page markdown copy
- **`iptv-tech-builder`** — scaffolds the Astro project for a new country
- **`iptv-seo-auditor`** — runs schema, Lighthouse, link, a11y checks

### Hooks
- **`post-deploy-gsc`** — auto-submits sitemap to Google Search Console after every Cloudflare deploy

## Installation

```bash
claude plugin install github:mooizo/iptv-fleet-plugin
```

Then in any Claude Code session inside the `iptv-fleet/` repo:

```
/iptv-status                  # see the fleet
/iptv-new DE                  # start a new German site
/iptv-deploy DE               # ship it
/iptv-refresh-seo DE          # refresh Semrush data
```

## Requirements

- **Claude Code** with these MCP servers connected: `semrush`, `github`, `gsc`
- **CLI tools** on `$PATH`: `gh`, `pnpm` (≥9), `wrangler`
- **Env vars** in `~/.claude/settings.json`: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`
- **Companion repos cloned**:
  - `iptv-fleet` (your working directory when you run commands)
  - `seo-data-store` at `~/.claude/skills/seo-data-store/`

## Architecture

```
iptv-fleet-plugin/
├── .claude-plugin/plugin.json
├── skills/
│   ├── build-iptv-site/           # the 8-step pipeline
│   ├── iptv-brand-logo-prompt/    # ChatGPT prompt for SVG logos
│   └── iptv-fleet-orchestrator/   # decides which sub-skill/agent runs
├── commands/
│   ├── iptv-status.md
│   ├── iptv-new.md
│   ├── iptv-deploy.md
│   └── iptv-refresh-seo.md
├── agents/
│   ├── iptv-seo-writer.md
│   ├── iptv-tech-builder.md
│   └── iptv-seo-auditor.md
└── hooks/
    └── post-deploy-gsc.sh
```

## License

Private — not for redistribution.
