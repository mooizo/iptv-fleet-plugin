# API Dependencies & Budget

Every external API the pipeline touches, what it's used for, how much it costs per market, and the daily caps that prevent runaway spend.

## Required credentials (`.env`)

| Variable | Purpose | Where it's used |
|---|---|---|
| `DATAFORSEO_LOGIN` + `DATAFORSEO_PASSWORD` | Keyword research, SERP pulls, difficulty, related keywords | Step 01 |
| `FIRECRAWL_API_KEY` | Competitor homepage/pricing/devices scraping | Step 02 |
| `PERPLEXITY_API_KEY` + `PERPLEXITY_MODEL=sonar-pro` | Live market intelligence + per-competitor fact-check | Step 02 |
| `ANTHROPIC_API_KEY` + `ANTHROPIC_MODEL=claude-sonnet-4-6` | Synthesis (competitor scan), content writing (iptv-seo-writer) | Steps 02, 04 |
| `GEMINI_API_KEY` + `GEMINI_IMAGE_MODEL=gemini-2.5-flash-image` | Hero, OG, device mockup image generation | Step 06 |

## Optional credentials (audit + deploy)

| Variable | Purpose |
|---|---|
| `PSI_API_KEY` | Google PageSpeed Insights (25k requests/day free with key) |
| `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` | Programmatic Pages deploy + DNS |
| `GSC_SERVICE_ACCOUNT_JSON` | Google Search Console URL Inspection for post-deploy indexing checks |

## Auth conventions

- **DataForSEO** uses HTTP Basic Auth (email + password), NOT bearer token. Common mistake.
- **Perplexity, Gemini, Anthropic** all use `Authorization: Bearer {key}`.
- **Firecrawl** uses `Authorization: Bearer {key}` via their SDK.

## Daily budget caps (optional env vars)

Leave blank for unlimited. Tool respects these in `tools/_lib/budget.py` — API call aborts if the day's spend exceeds the cap.

| Variable | Default | Notes |
|---|---|---|
| `DATAFORSEO_DAILY_MAX` | blank | ~$0.02/market baseline |
| `FIRECRAWL_DAILY_MAX_CREDITS` | blank | Free tier 500/month ≈ 25 markets |
| `PERPLEXITY_DAILY_MAX` | blank | ~$0.02/market |
| `ANTHROPIC_DAILY_MAX` | blank | ~$0.15/market for scan, ~$0.50 for writer |
| `GEMINI_DAILY_MAX` | blank | ~$0.05–0.15/market for 15 images |

## Cost per full market build

From the IPTV Helder NL build:

| Step | API | Cost |
|---|---|---|
| 01 Keyword research | DataForSEO | ~$0.02 |
| 02 Competitor scan | Firecrawl + Perplexity + Claude | ~$0.17 |
| 04 Content writing | Anthropic (Claude Sonnet 4.6) | ~$0.45–0.60 |
| 06 Image generation | Gemini 2.5 Flash Image | ~$0.05–0.15 |
| **Total per market** | | **~$0.70–0.95** |

For 21 European markets in one refresh: **~$15–20 total**.

## Free-tier-friendly mode

If you're on free tiers everywhere:
- **Firecrawl:** 500 credits/month → 25 markets/month
- **DataForSEO:** $1 free trial credit → enough for ~5 markets of keyword research
- **Perplexity:** $5 minimum top-up → covers ~250 markets
- **Anthropic:** No free tier; requires paid account
- **Gemini:** Generous free tier on Flash Image

**Cheapest fast-path:** Skip Perplexity (`--skip-perplexity`), use cached DataForSEO data, and write content in bursts to stay within Anthropic free-credit windows.

## Rate limits learned

- **DataForSEO** `keyword_ideas` caps at 1000 results per call — batch seeds, don't pass all at once.
- **DataForSEO** occasionally returns zero SERP data for small-country language combos (e.g. `ar_MA`). Fall back to the broadest language code.
- **Perplexity** rate-limits aggressive polling; the tool adds exponential backoff with jitter.
- **Anthropic** Sonnet 4.6 rarely hits limits during normal use, but a market with 20+ blog posts can push past the tier 1 rate cap — spread the writer calls over multiple minutes or upgrade tier.
- **Firecrawl** 1500ms JS wait is the default — see `competitor-scan-gotchas.md` for when to bump it.

## `.tmp/` layout (per market)

All intermediate artifacts written by the tools:

```
.tmp/
└── {country}_{language}/           # e.g. NL_nl, DE_de, FR_fr
    ├── keywords.json               # step 01 output
    ├── serps.json                  # step 01 top-10 per keyword
    ├── keyword_cache.json          # DataForSEO cache (7-day TTL)
    ├── competitors.json            # step 02 top-5 domains
    ├── competitor_reports.json     # step 02 per-competitor structured
    ├── market_intelligence.md      # step 02 Perplexity briefing
    ├── gap_analysis.md             # step 02 Claude synthesis
    ├── verified_claims.json        # step 02 numeric facts + source URLs
    ├── perplexity_cache/           # step 02 cache (3-day TTL)
    ├── page_map.json               # step 03 output
    ├── blog_backlog.json           # step 03 blog topic queue
    ├── content/                    # step 04 markdown files
    │   ├── index.md
    │   ├── pricing.md
    │   ├── devices/
    │   └── blog/
    ├── images/                     # step 06 generated WebP
    └── audit_report.json           # step 07 full audit results
```

`.tmp/` is disposable by design. Regenerate from the previous step if anything goes wrong — never hand-edit these files.
