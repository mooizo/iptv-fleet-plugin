---
description: Scaffold and build a new country site. Usage:/iptv-new {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. DE, FR, ES, IT, UK, PT)"
---

# /iptv-new {country}

Scaffold a new country site under `sites/{cc}/` and run the full build pipeline.
Idempotent: re-running picks up from the last completed step (status field in `fleet.config.yaml`).

## What to do

### 1. Validate input
- Argument must be ISO-3166 alpha-2 (e.g. `DE`, `FR`, `UK`). Normalize to lowercase.
- If missing/invalid, ask the user via `AskUserQuestion`.

### 2. Load `fleet.config.yaml`
- Path: `./fleet.config.yaml` (assume cwd is the monorepo root; if not, error out and tell the user to `cd` there).
- Find the entry under `countries.{cc}`.
- If the entry doesn't exist, add a stub with `status: planned` and continue.

### 3. Resume logic based on status

| Current status | Action |
|---|---|
| `planned` | Run full Phase A + Phase B, then pipeline steps 1–7 |
| `building` | Resume from the step recorded in `.tmp/{COUNTRY}_{lang}/last_completed_step` |
| `built` | Skip to `/iptv-deploy {cc}` suggestion (ask user) |
| `live` | Ask user: "Already live. Do you want to (a) re-pull SEO data, (b) re-build, (c) cancel?" |
| `paused` | Tell user the site is paused; ask if they want to resume |

### 4. Phase A — Branding (only ask missing fields)

For each field NOT already populated in the country entry, ask via `AskUserQuestion`:

| Field | If missing, ask |
|---|---|
| `brand_name` | "What's the brand name for the {COUNTRY} site? (e.g. IPTV Klar)" |
| `domain` | "What's the domain? (e.g. iptvklar.de)" |
| `palette.primary` + `.secondary` + `.accent` | Run the branding sub-flow from `skills/build-iptv-site/SKILL.md` Phase A |
| `font` | Default Plus Jakarta Sans unless user specifies |
| `design_personality` | Pick from professional/bold/sleek/energetic/warm |
| `usp` | List 3–5 differentiators |
| `contact.email` + `.whatsapp` | Support channels |
| `payment_methods` | Local payment options |
| `trial_offer` | e.g. "24-Stunden Gratis-Test" |

After collecting, **write back to `fleet.config.yaml`**. The yaml file is the source of truth.

### 5. Logo (optional)

Ask: "Do you want to generate a logo prompt now? (y/n)"
If yes, invoke the `iptv-brand-logo-prompt` sub-skill. User pastes the resulting SVG to `sites/{cc}/public/logo.svg`.

### 6. Phase B — SEO data (cache-first)

Check `~/.claude/skills/seo-data-store/data/{COUNTRY}/latest.json`:
- Exists AND `last_updated` ≤ 30 days old? → **use cache**, copy contents into `.tmp/{COUNTRY}_{lang}/keyword_universe.json` and `competitor_list.json`
- Stale or missing? → invoke the `seo-data-store` skill to refresh, then read.

Mark status: `building`. Write `.tmp/{COUNTRY}_{lang}/last_completed_step = 0`.

### 7. Pipeline steps 03–07

Invoke the `build-iptv-site` skill's workflows:
- 03 intent_cluster.py → page_map.json
- 04 write_content (spawn iptv-seo-writer agent) → markdown files in `sites/{cc}/src/content/`
- 04 content_linter.py
- 05 tech-builder (spawn iptv-tech-builder agent) → `sites/{cc}/src/pages/`, `astro.config.mjs`, `tailwind.config.mjs`, `package.json`, `brand.yaml`
- 06 generate_all_images.py → `sites/{cc}/public/images/`
- 07 audit (a11y, link, pagespeed, schema)

After each step, write `.tmp/{COUNTRY}_{lang}/last_completed_step = N` so resume works.

### 8. Mark built

Update `fleet.config.yaml`:
- `status: built`
- `last_built: <UTC ISO timestamp>`

Tell the user the site is ready and offer `/iptv-deploy {cc}`.

## Hard rules

- **NEVER overwrite a field in `fleet.config.yaml`** that's already populated unless the user explicitly confirms.
- **NEVER skip the cache check** — Semrush API units are expensive.
- **NEVER bypass Phase A** if any field is missing — the writer agent needs them all.
- **ALWAYS write back to `fleet.config.yaml` and commit** at the end (use `git add fleet.config.yaml && git commit -m "fleet: {cc} built"`).
