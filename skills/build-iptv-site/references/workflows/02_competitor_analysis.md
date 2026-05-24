# Workflow: Competitor Analysis (Firecrawl + Perplexity + Claude)

**Goal:** Teardown the top 5 ranking IPTV competitors in `target_country`, fact-check their claims with live web research, and produce a gap analysis that drives content differentiation in `04_write_content.md`.

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

## Step 3 — Outputs

| File | Content | Used by |
|---|---|---|
| `competitors.json` | Top 5 domain list | Reference |
| `competitor_reports.json` | 5 structured reports (scrape + fact-check + extraction) | Writer agent |
| `gap_analysis.md` | Strategic brief | Writer agent |
| `verified_claims.json` | Every numeric claim with source URL | Content linter (`tools/content_linter.py`) |
| `market_intelligence.md` | Live briefing from Perplexity | Writer agent (for current-events context) |

---

## Step 4 — Cost estimate per run

Typical 1-market run:
- **Firecrawl:** ~20 scrapes (5 competitors × 4 paths) = 20 credits (free tier: 500/month)
- **Perplexity:** 6 calls (1 market briefing + 5 fact-checks) ≈ $0.02
- **Anthropic:** 6 calls (5 extractions + 1 gap analysis), ~30k input tokens + 12k output ≈ $0.15

**Total: ~$0.17/market.** 21 European markets ≈ $3.60 per full round. Monthly refresh budget: ~$4.

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
Pass `gap_analysis.md`, `verified_claims.json`, and `market_intelligence.md` to `03_intent_mapping.md` (for page map) and `04_write_content.md` (for writer context).
