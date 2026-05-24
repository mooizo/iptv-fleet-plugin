# SEMrush API Unit Budget Rules

> Read this **before** calling any `mcp__semrush__*` tool. These rules exist because the user's plan is capped at 50,000 API units / 12 months (refills May 31, 2026). One careless batch can burn 5% of the annual budget.

**Companion to:** `api-budget.md` (covers DataForSEO/Firecrawl/Perplexity). This file covers ONLY the SEMrush MCP at `https://mcp.semrush.com/v1/mcp`.

---

## The 49,680-unit reality

| Unit ledger | Value |
|---|---|
| Annual allocation | 50,000 |
| Already spent (session of 2026-05-20) | ~320 |
| Effective remaining | 49,680 |
| Refill date | 2026-05-31 |
| Hard weekly cap | **500 units** |
| Hard per-call cap (no user confirmation) | **500 units** in a single call |
| 12-month forecast (12 country markets × ~620u launch + 12×100u/mo ongoing) | ~17,000 |
| Reserve | ~32,000 (safety + lead-market deep-dives) |

---

## Tier-1 (lead market) vs Tier-2 (everyone else)

**Lead market** = the first/highest-priority country we research deeply. The data we collect there gets **translated/transposed** to other markets for free instead of being re-pulled. Currently the lead market is **SE (Sweden)**. UK and DE are the next obvious lead markets if/when traffic justifies it.

**Tier-2 markets** = every other country in the rollout list. They get the cheap research path: SEMrush for the unique-per-country head term SERP, and DataForSEO + Firecrawl + GSC for everything else.

| Action | Lead market | Tier-2 market |
|---|---|---|
| `phrase_organic` (SERP for "iptv") | ✅ via SEMrush, `display_limit=30` (300u) | ✅ via SEMrush, same call (300u — needed per country, can't translate) |
| `phrase_this` head term | ✅ (10u) | ✅ (10u) |
| `phrase_related` for "iptv" | ✅ (2,000u for 50 lines) | ❌ Use `dataforseo_labs_google_related_keywords` instead (free under subscription) |
| `phrase_kdi` (keyword difficulty) | ✅ shortlist top-10 only (500u) | ❌ Use DataForSEO's KD instead |
| `phrase_questions` | ✅ (1,200u) | ❌ Translate lead-market questions; question intent is universal |
| `domain_organic` per competitor | ✅ top-3 competitors, `display_limit=100` (3,000u) | ⚠ Top-3 competitors, `display_limit=10` only (300u total) |
| `backlinks_refdomains` per competitor | ✅ `display_limit=50` (2,000u) | ❌ Skip; backlink data ages slowly — once-per-region per year is enough |
| `siteaudit_research` | ✅ FREE — bills against Pages-to-Crawl (300k/mo) | ✅ FREE — same |
| `tracking_research` (rank tracking) | ✅ FREE — bills against Keywords quota (1,500/mo) | ✅ FREE — same |
| `url_research → url_organic` on our deployed homepage | ✅ (20u) | ✅ (20u) |

---

## Per-call cost reference (live)

Costs are taken from each report's `get_report_schema` description. Verify with `get_report_schema(report=...)` before any batch.

| Report | Toolkit | Cost | Use when |
|---|---|---|---|
| `domain_rank` | overview_research | 10 u / line | Quick domain snapshot |
| `domain_rank_history` | overview_research | 10 u / line | Trend (one row = one month) |
| `rank_difference` | overview_research | 20 u / line | Market-level gainers/losers |
| `phrase_this` | keyword_research | 10 u | Single keyword metrics |
| `phrase_these` | keyword_research | 10 u / keyword | Bulk (semicolon-joined, max 100 per call) |
| `phrase_related` | keyword_research | **40 u / line** ⚠ | Lead market only |
| `phrase_questions` | keyword_research | **40 u / line** ⚠ | Lead market only |
| `phrase_fullsearch` | keyword_research | 20 u / line | Exhaustive variants of a phrase |
| `phrase_kdi` | keyword_research | **50 u / line** ⚠ | Shortlisted top-10 only |
| `phrase_organic` (SERP) | keyword_research | 10 u / line | `display_limit=30` default |
| `phrase_adwords` | keyword_research | 20 u / line | Paid SERP (rarely needed for IPTV) |
| `phrase_adwords_historical` | keyword_research | **100 u / line** 🚫 | Avoid — almost never worth it |
| `domain_organic` | organic_research | 10 u / line | Competitor keyword pull |
| `backlinks_refdomains` | backlink_research | ~40 u / line | Lead market only |

---

## Hard rules (enforced for every agent / session)

1. **Check `.tmp` first.** Before any SEMrush call, check `<project>/.tmp/{cc}_{lang}/semrush/` for an existing CSV with the same parameters. If one exists and is < 30 days old, **read the file** — do not re-run.
2. **`display_limit` defaults to 30, never above 50** for any `phrase_organic` / `domain_organic` call unless the user explicitly asks for more.
3. **Batch with `phrase_these`** (semicolon-joined keywords) instead of N×`phrase_this` calls.
4. **Lead-market gating.** Any call to `phrase_related`, `phrase_kdi`, `phrase_questions`, or `backlinks_refdomains` runs against the lead-market database only. For other markets, route through `dataforseo` MCP equivalents.
5. **One-shot per country per phase.** Each Phase (1–5 in the ranking system) runs **once** per country per launch. Re-runs require an exception line in `~/viking-iptv/SEMRUSH_USAGE.md`.
6. **Save raw CSV.** Every report's raw response gets written verbatim to `<project>/.tmp/{cc}_{lang}/semrush/{NN}_{report}.csv`. No exceptions.
7. **Weekly cap = 500 units.** Sum all calls in the rolling 7-day window. If a planned call would push the rolling sum over 500, defer to the next week or downgrade to a tier-2 (DataForSEO) substitute.
8. **Per-call cap = 500 units.** Any single call costing more than 500u (e.g. `phrase_related` with `display_limit=50` = 2,000u) requires explicit user confirmation. The `phrase_related` lead-market exception is acceptable because it produces high-leverage data, but it must be ONCE per region per year.
9. **Site Audit + Position Tracking are free** against the 49,680 budget — they bill against separate Pages-to-Crawl and Keywords pools. Prefer these over their API-unit equivalents.
10. **Log every call.** Append a one-liner to `~/viking-iptv/SEMRUSH_USAGE.md` after each session: `YYYY-MM-DD | {tool} | {params} | {cost_u} | {output_path}`.

---

## Pre-flight checklist (paste into your head before any session)

```
[ ] Did I check .tmp/{cc}_{lang}/semrush/ for existing data?
[ ] Is this the lead market, or am I about to call a Tier-1-only tool against a Tier-2 country?
[ ] Is `display_limit` set to 30 or less?
[ ] Am I batching via phrase_these where possible?
[ ] Will this call exceed 500u? If yes, did I confirm with the user?
[ ] Is the rolling 7-day spend + this call still under 500u? If no, defer or downgrade.
[ ] After the call, will I save the CSV to .tmp and log to SEMRUSH_USAGE.md?
```

---

## Substitute matrix — what to use instead of SEMrush

When the budget rules prohibit a SEMrush call, route to one of these (all already connected as MCPs):

| Want this data | SEMrush call (avoid) | Free/cheap substitute |
|---|---|---|
| Related keywords | `phrase_related` | `dataforseo_labs_google_related_keywords` (DataForSEO Labs) |
| Keyword difficulty | `phrase_kdi` | `dataforseo_labs_bulk_keyword_difficulty` |
| Long-tail / questions | `phrase_questions` | DataForSEO `keyword_suggestions` filter + intent classifier |
| Competitor top keywords | `domain_organic` with display_limit=100 | `dataforseo_labs_google_ranked_keywords` |
| Competitor backlinks (refdomains) | `backlinks_refdomains` | `dataforseo.backlinks_referring_domains` (much cheaper per request) |
| Live SERP for a query | `phrase_organic` | `dataforseo.serp_organic_live_advanced` |
| Competitor copy / on-page content | n/a (not a SEMrush feature) | `firecrawl.firecrawl_scrape` |
| Real-world click data for OUR site | n/a | `gsc.*` (Google Search Console) |
| Topical / news angle | n/a | `perplexity.perplexity_ask` |

**Rule of thumb:** SEMrush wins for **authoritative SERP snapshots, keyword difficulty index, and backlink intelligence**. For everything else, DataForSEO/Firecrawl/GSC are equal or better at lower cost.

---

## When to break these rules

- The user explicitly asks for a deep-dive on a tier-2 market and acknowledges the cost.
- We just launched a new country site and need a 30-day post-launch positions snapshot.
- A major competitor showed up out of nowhere (Phase 7 monthly loop flagged it) and we need to map their full keyword profile.

In all three cases: log the exception in `SEMRUSH_USAGE.md` with the cost and the reason.
