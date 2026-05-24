# Workflow 01a — SEMrush Enrichment (optional, runs after 01)

**Goal:** Layer authoritative SERP, keyword-difficulty, and competitor-keyword data from SEMrush onto the DataForSEO keyword universe built in step 01. Identifies the 3 strongest direct competitors and feeds their keyword strategy into the competitor scan (step 02).

**Status:** Optional, opt-in. If SEMrush MCP is unavailable or the user is out of API units, **skip this workflow** — the pipeline still works end-to-end on DataForSEO data alone.

**Prerequisite:** Workflow `01_keyword_research.md` already ran and produced `.tmp/{cc}_{lang}/keywords.json`.

**Budget governance:** Read `references/semrush_budget_rules.md` BEFORE executing any call here. Hard caps: 500u/week, 500u/single call without user confirmation.

---

## Required inputs

| Input | Source |
|---|---|
| `cc` (country code, lower) | from build-iptv-site Phase A |
| `lang` (ISO 639-1) | from build-iptv-site Phase A |
| `database` (SEMrush database code) | usually = `cc`; see `mcp__semrush__get_report_schema(report="phrase_this")` for valid list |
| `head_term` | the localized "iptv" term (e.g. `iptv` for SE/DE/FR/UK, same word everywhere — rarely localized) |
| `is_lead_market` | boolean. **First country we research deeply = lead market.** All others = tier-2. See `semrush_budget_rules.md`. |
| `top_competitors` | 3 domains identified from step 01's SERP pull (or from this workflow's Phase 1 output) |

---

## Phase 1 — Market & SERP intelligence (~310 units, both lead and tier-2)

Pulls the authoritative top-30 SERP and head-term metrics from SEMrush. Cannot be substituted — this is SEMrush's strength.

### Steps

1. **`mcp__semrush__execute_report(report='rank_difference', params={database: cc, display_limit: 30})`** — 20u-equivalent for the top 30 lines × 1 line = 20u (called as a single market snapshot — 20u total). Captures who's rising/falling in the IPTV niche in this market. Save raw CSV to `.tmp/{cc}_{lang}/semrush/01a_rank_difference.csv`.

2. **`mcp__semrush__execute_report(report='phrase_this', params={phrase: head_term, database: cc})`** — 10u. Save to `.tmp/{cc}_{lang}/semrush/01a_phrase_this.csv`.

3. **`mcp__semrush__execute_report(report='phrase_organic', params={phrase: head_term, database: cc, display_limit: 30})`** — 300u (10u/line × 30). Save to `.tmp/{cc}_{lang}/semrush/01a_phrase_organic.csv`.

### Output

Write a 1-page summary to `.tmp/{cc}_{lang}/semrush/01a_market_summary.md` containing:

- **Search volume** for the head term
- **CPC + competition** (paid)
- **Top 10 organic competitors** (deduplicated domains from `phrase_organic`)
- **SERP feature mix** (which SERP feature codes appear)
- **Page-1 anatomy notes** (homepage vs blog vs informational mix)

Set `top_competitors` = the 3 strongest direct subscription competitors from this list (exclude Wikipedia, news, retailers).

---

## Phase 2 — Keyword universe enrichment

### Lead market

1. **`phrase_related`** for `head_term`, `display_limit=50` — **2,000u**. Save to `.tmp/{cc}_{lang}/semrush/02a_phrase_related.csv`.
2. Build candidate list of ~30 keywords (seeds from step 01 + new relateds + intent-tagged variants).
3. **`phrase_these`** with the 30 candidates (semicolon-joined) — 300u. Save to `.tmp/{cc}_{lang}/semrush/02a_phrase_these.csv`.
4. From candidates with SV > local threshold, take top-10 commercial-intent → **`phrase_kdi`** — 500u. Save to `.tmp/{cc}_{lang}/semrush/02a_phrase_kdi.csv`.

**Total: ~2,800u — lead market only, once per region per year.**

### Tier-2 market

Skip SEMrush — use DataForSEO (workflow 01 already ran). Run **`phrase_these`** ONLY for the final shortlist of 30 keywords to get SEMrush-authoritative SV — 300u. Save to `.tmp/{cc}_{lang}/semrush/02a_phrase_these.csv`.

**Total: ~300u — tier-2.**

### Merge

Update `.tmp/{cc}_{lang}/keywords.json` with SEMrush-authoritative columns where they differ from DataForSEO. Tag the source per row (`source: semrush|dataforseo`).

---

## Phase 3 — Competitor extraction

For each of the 3 `top_competitors` identified in Phase 1:

### Lead market

1. **`mcp__semrush__execute_report(report='domain_organic', params={domain, database: cc, display_limit: 100})`** — 1,000u/competitor × 3 = **3,000u**. Save to `.tmp/{cc}_{lang}/semrush/03a_{competitor_slug}_organic.csv`.
2. **`mcp__semrush__execute_report(report='backlinks_refdomains', params={target: competitor, target_type: "root_domain", display_limit: 50})`** — ~2,000u/competitor × 3 = **6,000u**. ⚠ Requires user confirmation per `semrush_budget_rules.md` (per-call cap). **Recommend running ONE competitor at a time and only the top-1.** Save to `.tmp/{cc}_{lang}/semrush/03a_{competitor_slug}_refdomains.csv`.

**Realistic lead-market spend:** ~3,000u for keyword extraction + 2,000u for backlinks of the top-1 competitor = **~5,000u**. Spread across calendar quarters per the weekly cap.

### Tier-2 market

1. **`domain_organic`** with `display_limit=10` per competitor — 100u × 3 = **300u**. Save same path.
2. Skip backlinks entirely. Use lead-market backlink data as proxy.

### Pair with Firecrawl

For each competitor, call **`mcp__firecrawl__firecrawl_scrape`** on the homepage and pricing page — free under subscription. Save markdown to `competitor-copy-text/{competitor_slug}.md` matching the existing `streaming-nordic-full-page.md` pattern.

---

## Output files (all written under `.tmp/{cc}_{lang}/semrush/`)

| File | Content | Phase |
|---|---|---|
| `01a_rank_difference.csv` | Market gainers/losers | 1 |
| `01a_phrase_this.csv` | Head term metrics | 1 |
| `01a_phrase_organic.csv` | Top-30 SERP for head term | 1 |
| `01a_market_summary.md` | 1-page human-readable summary | 1 |
| `02a_phrase_related.csv` | Lead market only | 2 |
| `02a_phrase_these.csv` | Bulk keyword metrics | 2 |
| `02a_phrase_kdi.csv` | Lead market only | 2 |
| `03a_{slug}_organic.csv` | Top keywords per competitor | 3 |
| `03a_{slug}_refdomains.csv` | Lead market top-1 competitor only | 3 |

And under `<project>/competitor-copy-text/`:

| File | Content |
|---|---|
| `{competitor_slug}.md` | Firecrawl scrape of competitor homepage + pricing |

---

## Hand-off

The enriched outputs feed:

- **Step 02 (`02_competitor_analysis.md`)** — uses `03a_*` files + competitor scrapes
- **Step 03 (`03_intent_mapping.md`)** — uses enriched `keywords.json`
- **Step 04 (`04_write_content.md`)** — uses `01a_market_summary.md` for SERP-feature targeting (FAQ, Review, Video schema)

---

## Budget reconciliation

After running this workflow, append a session entry to `~/viking-iptv/SEMRUSH_USAGE.md` (or whichever project's USAGE file applies):

```
YYYY-MM-DD | workflow 01a | {cc}_{lang} | lead=true|false | {total_u} u | .tmp/{cc}_{lang}/semrush/
```

If the project doesn't have a `SEMRUSH_USAGE.md` yet, create it with the header `# SEMrush API Unit Usage Log\n` + the first entry.
