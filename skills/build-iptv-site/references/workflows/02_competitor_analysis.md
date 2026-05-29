# Workflow: Competitor Analysis (Firecrawl + Perplexity + Claude)

**Goal:** Teardown the top 5 ranking IPTV competitors in `target_country` along **two axes** and produce artifacts that drive the rest of the pipeline:
1. **Positioning teardown** (pricing, claims, USPs, market intelligence) → drives content *differentiation* in `04_write_content.md`. *(Stages 1–3 below — unchanged.)*
2. **On-page ranking-factor teardown** (the structural patterns that actually correlate with ranking + the competitor weaknesses to exploit) → drives *structure* decisions in `03_intent_mapping.md`, `05_build_astro.md`, `04_write_content.md`, and `07_seo_audit.md`. *(Stage 4 below — added after the DE launch proved this is the higher-leverage axis.)*

> **Why axis 2 matters (learned from the DE/IPTV Klar launch):** a positioning teardown tells you what to *say*; it does not tell you what structure *ranks*. When we scraped the 5 DE competitors' actual ranking URLs we found their rankings came from (a) **content-cluster breadth** — a library of app/device how-to guides targeting low-KD long-tail (KD 2–13) — and (b) **off-page authority**, NOT from superior on-page structure (we already matched/beat them on schema depth, word count, internal links, locale correctness). Axis 2 captures the structural norm to match + the cluster gap to fill + the weaknesses to exploit. See `references/competitor-ranking-playbook.md` for the full pattern library.

**Tool stack:**
- **Firecrawl** — scrapes competitor homepages, pricing pages, and device pages. Source of verifiable pricing and channel counts.
- **Perplexity** — live market intelligence and per-competitor fact-checking with citations (reputation, recent changes, news).
- **Claude** (Anthropic API) — synthesizes everything into structured reports + gap analysis.

Why three tools? Firecrawl gives us verbatim facts. Perplexity gives us what's happening *right now* in the market. Claude fuses both into clean structured output. No single tool does all three well.

---

## Required Inputs
- `.tmp/{country}_{lang}/serps.json` from workflow 01
- `target_country`, `target_language`
- `.env` with `FIRECRAWL_API_KEY`, `PERPLEXITY_API_KEY`, `ANTHROPIC_API_KEY`

---

## Step 1 — Identify Top 5 Competitors

Unchanged from before. From `serps.json`, count domain frequency across the top-10 SERPs for the top 20 commercial-intent keywords. The 5 most-frequent domains (after applying `tools/_lib/competitor_blocklist.json`) are the target set.

Save to `.tmp/{country}_{lang}/competitors.json`.

---

## Step 2 — Run the hybrid scan

```bash
python tools/competitor_scan.py --country FR --language fr
```

The tool runs three stages:

### Stage 1 — Firecrawl scrape
For each of the 5 competitors, scrape these paths:
- `/` (homepage)
- `/pricing` and `/plans` (pricing pages — try both since different sites use different paths)
- `/devices` (device compatibility info)

Each successful scrape returns clean markdown from Firecrawl's `onlyMainContent` mode with a 1500ms JS render wait.

**Failure handling:** If Firecrawl can't scrape a site (hit with Cloudflare challenge, site timeout), log a warning and continue. Stage 3 (Claude) will still produce a partial report using whatever was scraped plus Perplexity data.

### Stage 2 — Perplexity discovery
Two sub-calls per run:

**2a. Market intelligence briefing** (one call per run):
```
Research prompt: current market intelligence for IPTV in {country_name}
Returns: markdown briefing with citations covering
  - Dominant providers in last 30 days
  - Legal/regulatory developments (last 6 months)
  - Top 3 most-searched IPTV questions
  - Current sporting events driving demand
  - Typical local-currency price points
  - Emerging trends
```
Saved to `.tmp/{c}_{l}/market_intelligence.md`.

**2b. Per-competitor fact-check** (one call per competitor = 5 calls):
```
Research prompt: for {domain} in {country_name}, verify
  - Reputation (last 6 months of reviews)
  - Pricing changes (last 3 months)
  - Recent news (legal, rebrand, features)
  - Primary USP in this specific country
Returns: JSON with source URLs for every claim
```
Cached for 3 days (Perplexity responses vary slightly; caching avoids re-billing for the same market within a work week).

### Stage 3 — Claude synthesis
Two Claude calls per run:

**3a. Per-competitor structured extraction** (5 calls — one per competitor):
Claude receives the Firecrawl scrape + Perplexity fact-check for one competitor and returns a `CompetitorReport` JSON object matching the schema in `agents/iptv-seo-writer.md` plus `reputation_summary` and `recent_changes` fields from the Perplexity data.

**3b. Gap analysis** (1 call per run):
Claude receives all 5 reports + the market intelligence briefing and produces `gap_analysis.md` with sections:
- Price positioning (floor/median/ceiling + recommendation)
- Saturated claims (avoid repeating)
- Differentiation opportunities
- Priority content gaps (mapped to concrete pages/posts)
- Market-specific insights from live research
- Final positioning recommendation (2–3 sentences)

---

## Stage 4 — On-page ranking-factor teardown (the higher-leverage axis)

This stage does NOT re-scrape competitor homepages for positioning. It scrapes the **exact URLs that actually rank** (from the keyword footprint) and extracts the *structural* signals that correlate with ranking, plus each competitor's exploitable weaknesses.

### 4a — Pick the ranking URLs to scrape (not the homepages)
From the keyword footprint (`build_keyword_footprint`, domain → [{keyword, position}]) and the per-keyword SERP/gap data, dedupe every competitor URL that ranks, score each page by **page-opportunity** = Σ over the keywords it ranks for of `volume × (1 − KD/100)`, and take the **top ~15 pages** (guarantee each competitor's homepage + best money page is represented). This is the method validated in the DE launch — it surfaces the pages worth modeling, not arbitrary paths.

> If only `serps.json` exists (no gap file), fall back to: each competitor's top-3 ranking URLs by position.

### 4b — Scrape each ranking URL for on-page signals
Firecrawl with **JSON extraction** (`formats: ["json"]` + a schema) — NOT plain markdown — so one call returns the structured signals. Also keep the page `metadata` (Firecrawl returns it free) for `og:locale` / `generator` / `dateModified`.

Per-page schema to extract:
`title_tag, meta_description, h1, heading_outline (ordered H2/H3), approx_word_count, schema_types[] (JSON-LD @type), has_faq_section, faq_questions[], internal_links_count, trust_signals[], primary_keyword_in_title, pricing_shown, price_points[]`.
Plus from metadata: `og_locale`, `cms` (generator), `date_modified`.

**JS-render note:** money/pricing pages may need `waitFor: 5000`. Cache hits are cheap (Firecrawl caches by URL).

### 4c — Aggregate into `ranking_factors.json`
Compute the **structural norm** the rankers share + **per-domain weaknesses**:
```json
{
  "country": "DE",
  "scanned_pages": 13,
  "norm": {
    "schema_types_common": ["FAQPage", "Product"],
    "schema_types_max_seen": 2,
    "word_count_median": 1451,
    "word_count_p75": 2000,
    "faq_count_median": 5,
    "internal_links_median": 12,
    "pct_primary_kw_in_title": 1.0,
    "pct_with_faq_schema": 0.85
  },
  "content_clusters": {
    "money_page": ["smart-iptv-pro.de/iptv-kaufen/", "..."],
    "app_guides": ["tivimate-funktionen", "tivimate-installieren", "ibo-player", "iptv-smarters", "m3u-playlist"],
    "device_guides": ["fire-tv", "firestick", "smart-tv"],
    "listicles": ["beste-iptv-app-fire-tv-2026"],
    "owned_by": { "app_guides": "meiniptvanbieter.de", "...": "..." }
  },
  "weaknesses": [
    {"domain": "smart-iptv-pro.de", "issues": ["og:locale=en_US on a German site", "only 2 schema types"]},
    {"domain": "smartsho.store", "issues": ["no FAQ section on money page", "og:locale=en_US"]},
    {"domain": "beimulleriptv.com", "issues": ["stale dateModified (2025-03)", "thin 816 words", "keyword-stuffed headings"]}
  ]
}
```

### 4d — Claude synthesis → `ranking_playbook.md`
One Claude call turns `ranking_factors.json` into an actionable brief with these sections (the consumers read this file, not the raw JSON):
- **Structural norm to match-or-beat** — concrete targets: min schema set, word-count floor (= norm median, beat at p75), min FAQ count, min internal links, locale must be correct.
- **Content-cluster map** — which clusters the market rewards + which competitor owns each + which clusters a fresh site would be MISSING (→ becomes `blog_backlog` guide pages in step 03).
- **Exploit list** — per-competitor weaknesses we can out-cover (locale, missing FAQ, stale dates, thin content).
- **The two playbooks** (one-fat-money-page vs content-engine) and which the market rewards.

---

## Step 3 — Outputs

| File | Content | Used by |
|---|---|---|
| `competitors.json` | Top 5 domain list | Reference |
| `competitor_reports.json` | 5 structured reports (scrape + fact-check + extraction) | Writer agent |
| `gap_analysis.md` | Strategic positioning brief | Writer agent |
| `verified_claims.json` | Every numeric claim with source URL | Content linter (`tools/content_linter.py`) |
| `market_intelligence.md` | Live briefing from Perplexity | Writer agent (for current-events context) |
| **`ranking_factors.json`** | **On-page structural norm + content-cluster map + per-domain weaknesses** | **Intent-mapping (03), tech-builder (05), auditor (07)** |
| **`ranking_playbook.md`** | **Actionable ranking brief (norm to beat, clusters to fill, weaknesses to exploit)** | **Intent-mapping (03), tech-builder (05), writer (04), auditor (07)** |

---

## Step 4 — Cost estimate per run

Typical 1-market run:
- **Firecrawl:** ~20 positioning scrapes (Stages 1–3) + ~15 ranking-URL JSON scrapes (Stage 4) ≈ 35 credits (free tier: 500/month). Stage 4 reuses Firecrawl's URL cache, so refresh runs are cheaper.
- **Perplexity:** 6 calls (1 market briefing + 5 fact-checks) ≈ $0.02
- **Anthropic:** 7 calls (5 extractions + 1 gap analysis + 1 ranking_playbook synthesis), ~40k input + 15k output ≈ $0.18

**Total: ~$0.20/market.** Stage 4 uses **0 Semrush/DataForSEO units** — it scrapes already-known ranking URLs from the keyword footprint. 21 European markets ≈ $4.20 per full round.

---

## Step 5 — Fallback: skip Perplexity

If Perplexity is unavailable (rate-limited, budget exceeded, or in offline testing):

```bash
python tools/competitor_scan.py --country FR --language fr --skip-perplexity
```

The tool falls back to Firecrawl + Claude only. Quality drops because you lose live market intelligence and review-based reputation data, but pricing and feature extraction still work.

---

## Learned Constraints

- Firecrawl's `onlyMainContent` mode strips navigation/footer — great for reading body copy, but sometimes misses footer-only links (terms of service, refund policy). If you need those, add a second scrape with `onlyMainContent: false`.
- Some IPTV sites dynamically render pricing in JavaScript cart widgets that Firecrawl's 1500ms wait doesn't catch. When Claude reports "pricing: null" despite a scrape existing, manually check the scraped markdown — if no prices are there, the site is using a hidden cart. Document this in `.tmp/{c}_{l}/competitors.json` as `requires_manual_pricing: true`.
- Perplexity occasionally refuses to answer questions about specific IPTV brands citing "copyright concerns". When that happens, reword the prompt to ask about "the IPTV provider at {domain}" generically rather than by brand name.
- Claude sometimes hallucinates pricing from Perplexity's unstructured text if Firecrawl returned nothing. The extraction prompt explicitly says "only include pricing entries with a source_url that matches the scraped content" but verify by spot-checking — if `pricing` has entries but `scraped_by_domain[domain]` was empty, re-run with `--skip-perplexity` to force Claude to use only verified scrape data.

---

## Output Handoff

**Positioning axis:** Pass `gap_analysis.md`, `verified_claims.json`, and `market_intelligence.md` to `03_intent_mapping.md` (page map) and `04_write_content.md` (writer context).

**Ranking-factor axis:** Pass `ranking_playbook.md` + `ranking_factors.json` to:
- `03_intent_mapping.md` — the **content-cluster map** auto-plans the missing guide pages (the app-guide engine) into `blog_backlog`.
- `05_build_astro.md` (`iptv-tech-builder`) — the **structural norm** sets the schema set + word-count/heading/FAQ targets generated pages must hit.
- `04_write_content.md` (`iptv-seo-writer`) — the **exploit list** tells the writer which competitor weaknesses to out-cover.
- `07_seo_audit.md` (`iptv-seo-auditor`) — the **norm** becomes a competitive gate: warn if our page is below the competitor schema/word/FAQ median for its target keyword.
