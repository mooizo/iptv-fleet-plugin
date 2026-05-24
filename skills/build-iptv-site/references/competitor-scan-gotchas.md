# Competitor Scan Gotchas

Learned from building `tools/competitor_scan.py` during the IPTV Helder launch. Every one of these cost 30+ minutes of debugging — read them before running step 02 in a new market.

The pipeline has **three stages**: Firecrawl (scrape) → Perplexity (live research) → Claude (synthesis). Each stage has its own failure mode.

## Firecrawl

### Gotcha 1 — JS-rendered pricing missed

**Symptom:** Claude reports `pricing: null` for a competitor despite a successful scrape existing.

**Cause:** The competitor renders pricing inside a JavaScript cart widget (Stripe, WHMCS, custom) that Firecrawl's default 1500ms JS wait doesn't catch. The scraped markdown contains everything EXCEPT the prices.

**Fix:** Open `.tmp/{c}_{l}/competitor_reports.json` and manually grep the scraped content. If pricing isn't there, mark `requires_manual_pricing: true` in `competitors.json` and paste the prices in by hand from `verified_claims.json`.

**Prevent:** Bump the wait time in `competitor_scan.py` for known-dynamic sites, or add a second scrape with `onlyMainContent: false` (returns the footer too, where some sites stash price tables).

### Gotcha 2 — `onlyMainContent` strips legal pages

**Symptom:** You can't find the refund policy URL in the scrape.

**Cause:** Firecrawl's `onlyMainContent: true` mode strips nav and footer — which is where legal links live.

**Fix:** Second scrape pass with `onlyMainContent: false` for any competitor you need footer data from.

### Gotcha 3 — Cloudflare / bot challenges

**Symptom:** Firecrawl returns a 403 or the page content is the challenge page itself.

**Fix:** Enable Firecrawl's stealth mode (if available on your plan) or skip the competitor and flag `scrape_failed: true`. Stage 3 (Claude) still produces a partial report using Perplexity data only.

## Perplexity

### Gotcha 4 — Brand-name refusals

**Symptom:** Perplexity refuses to answer the per-competitor fact-check call, citing "copyright concerns" or "I can't provide information about that service."

**Cause:** Some IPTV brand names trigger Perplexity's content policy filters (especially brands with the word "stream" or names matching pirate sites).

**Fix:** Reword the prompt to ask about `the IPTV provider at {domain}` instead of using the brand name. Perplexity will happily research a domain name that it refuses to research as a brand name. Same data, different framing.

### Gotcha 5 — Thin responses for small markets

**Symptom:** Perplexity's market intelligence briefing for smaller markets (PT, PL, HU, GR) is thin — generic boilerplate instead of specific provider names and recent news.

**Fix:** Widen the prompt. Instead of "IPTV market in Portugal" ask "streaming subscription services and IPTV providers in Portugal, including pricing, legal status, and recent news." Perplexity's web index is sparser for smaller markets.

**Fallback:** `python tools/competitor_scan.py --skip-perplexity` — runs Firecrawl + Claude only. Quality drops (no live market context, no review-based reputation) but pricing/feature extraction still works.

### Gotcha 6 — 3-day cache

Perplexity responses vary slightly between calls even with the same prompt. The tool caches for 3 days to avoid paying for near-duplicate answers within a work week. If you need a fresh response (e.g. after a competitor rebranded), delete `.tmp/{c}_{l}/perplexity_cache/` before re-running.

## Claude (synthesis stage)

### Gotcha 7 — Hallucinated pricing from Perplexity text

**Symptom:** `competitor_reports.json` has pricing entries but `scraped_by_domain[{domain}]` was empty or the scrape returned a challenge page.

**Cause:** Claude reads Perplexity's unstructured text (which may mention prices secondhand) and fabricates `source_url` fields that don't match actual scraped content. This is the single most dangerous failure because it looks correct.

**Fix:**
1. The extraction prompt in `competitor_scan.py` requires every pricing entry to have a `source_url` that appears in the Firecrawl scrape. Spot-check after every run.
2. Re-run with `--skip-perplexity` to force Claude to use only verified scrape data.
3. In extreme cases, manually build `verified_claims.json` for that competitor.

### Gotcha 8 — Gap analysis generic on first run

**Symptom:** `gap_analysis.md` reads like boilerplate ("focus on price, focus on support") without market-specific insights.

**Cause:** The first Claude synthesis call sometimes under-utilizes the 5 reports + market intelligence briefing.

**Fix:** Re-run step 3b (`gap_analysis` synthesis) with a stricter prompt that explicitly requires: (a) specific competitor names in every bullet, (b) at least 3 numeric claims, (c) a named differentiation opportunity for each of the 5 competitors.

## Cost sanity check

Per-market budget from the build:
- Firecrawl: ~20 credits (free tier covers 25 markets/month)
- Perplexity: 6 calls ≈ $0.02
- Anthropic: 6 calls ≈ $0.15
- **Total ≈ $0.17 per market**

If a market exceeds $0.50, something's wrong — check cache hit rates and re-scrape logic.

## Blocklist

`tools/_lib/competitor_blocklist.json` filters out:
- Aggregator sites (Reddit, review blogs without original analysis)
- The brand's own domain and known sister brands
- Parked domains and expired redirects

Update the blocklist when you spot new offenders in step 1 (top-5 domain selection) — don't let them skew the competitive analysis.
