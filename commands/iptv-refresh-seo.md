---
description: Force-refresh Semrush data for a country, even if the cache is fresh. Usage:/iptv-refresh-seo {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. DE, FR)"
---

# /iptv-refresh-seo {country}

Force a Semrush data refresh for `{country}` via the `seo-data-store` skill,
bypassing the normal 30-day freshness check.

## When to use this

- A new Semrush keyword report came out and you want the latest volumes
- The user changed the country's competitor list in `fleet.config.yaml`
- A scheduled monthly refresh has triggered this command
- After a major content overhaul, before re-running the audit

## What to do

### 1. Validate
- Argument required: ISO-3166 alpha-2 (e.g. `DE`).
- Country must exist in `fleet.config.yaml`. If not, error.

### 2. Read competitor list
Get `countries.{cc}.competitors` from `fleet.config.yaml` if defined.
If not defined, the `seo-data-store` skill will discover competitors automatically.

### 3. Invoke `seo-data-store` skill

Use the Skill tool with these args:
- `country`: `{COUNTRY uppercase}`
- `competitor_domains`: array from fleet config (or omit)
- `force_refresh`: `true`  (bypass 30-day cache)

The skill will:
1. Call Semrush MCP for keyword research, organic research, backlinks, domain overview
2. Save to `~/.claude/skills/seo-data-store/data/{COUNTRY}/` as `keywords_YYYY-MM-DD.json`, etc.
3. Update `latest.json` pointer
4. Commit + push to `github.com/mooizo/seo-data-store`

### 4. Re-run intent mapping if keywords materially changed

Compare the new `keywords_YYYY-MM-DD.json` against the previous one:
- If >20% of top-50-by-volume keywords are NEW, re-run `tools/intent_cluster.py` for this country to regenerate `page_map.json`
- If the page_map changed, optionally suggest the user run `/iptv-new {cc}` to regenerate content (don't auto-trigger — content rewrite is expensive)

### 5. Update fleet.config.yaml

- `countries.{cc}.last_seo_refresh: <UTC ISO timestamp>`
- Commit + push

### 6. Report

```
✓ Semrush data refreshed for DE
  Files written: keywords_2026-05-24.json (327 keywords, +14 new since last pull)
                 competitors_2026-05-24.json (5 domains)
                 organic_iptvsnederland.com_2026-05-24.json
                 backlinks_*.json (5 files)
                 domain_overview_2026-05-24.json
  Credits used: ~14 units
  fleet.config.yaml.last_seo_refresh updated

Keyword change: 14/50 top-volume keywords are NEW.
Recommend: /iptv-new DE  (to regenerate content with the fresh page map)
```

## Hard rules

- **NEVER bypass the seo-data-store skill** — write directly to the cache. The skill handles dedup, schema validation, and the latest.json pointer.
- **NEVER force-refresh more than once per day** for the same country — Semrush API units are finite.
