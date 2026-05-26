---
description: Capture a GEO baseline — how often LLMs cite your site for top keywords. Uses DataForSEO (not Semrush). Usage:/iptv-geo-baseline {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. NL)"
---

# /iptv-geo-baseline {country}

Snapshot your site's current **LLM citation share-of-voice** for the top 50 keywords in `{country}`. This becomes the "before" benchmark — months from now we'll re-run and prove the GEO optimization work paid off.

**Touches Semrush: NO.** Uses DataForSEO's AI Optimization toolkit (the only one with LLM mention tracking).

## What to do

### 1. Validate
- Argument: ISO-3166 alpha-2 (e.g. `NL`)
- Verify `~/.claude/skills/seo-data-store/data/{COUNTRY}/keywords_*.json` exists. If not, error: "Run `/iptv-seo-ingest-{cc}` first."
- Verify `~/.claude/skills/seo-data-store/data/{COUNTRY}/keyword_gap_*.json` exists for commercial-intent filter.

### 2. Select top 50 query candidates
Read `keywords_{date}.json` and filter:
- `intent` contains `commercial` OR `transactional`
- `volume` ≥ 100
- Sort by volume desc
- Take top 50

Save the list as `~/.claude/skills/seo-data-store/data/{COUNTRY}/.geo_query_set_{date}.json` (hidden — internal).

### 3. Run LLM mention search per keyword

For each of the 50 keywords, call:

```
mcp__dataforseo__ai_opt_llm_ment_search
  query: "{the_keyword} {country_name}"   (e.g. "iptv abonnement Netherlands")
  llm_models: ["chatgpt", "claude", "perplexity", "gemini"]
  location: NL
  language: en  (the LLMs respond in EN even for NL queries 80% of the time)
```

For each response, capture:
- Was iptvhelder.nl mentioned? At what position in the answer (1st sentence, middle, footer)?
- Which competitors were mentioned? (cross-reference with the 5 competitor domains)
- What anchor text / link text was used?
- Which source URLs did the LLM cite?

Rate limit: DataForSEO LLM mentions API takes ~3-5 seconds per query × 4 LLMs × 50 keywords = ~10 minutes total. Use `mcp__dataforseo__ai_opt_llm_ment_search` once per keyword (it queries all 4 LLMs in one call if you pass them as an array).

### 4. Aggregate metrics

Call `mcp__dataforseo__ai_opt_llm_ment_agg_metrics` with:
- The full result set from step 3
- Group by: `llm_model`

Output per LLM:
- Total queries where we were mentioned
- Average mention position (lower = better — front of answer)
- Share of voice = (our mentions) / (our mentions + competitor mentions) × 100

Also call `mcp__dataforseo__ai_opt_llm_ment_top_domains` and `mcp__dataforseo__ai_opt_llm_ment_top_pages` to see which domains and URLs the LLMs cite most often in this niche — this tells us what to model our content after.

### 5. Save baseline

Write to `~/.claude/skills/seo-data-store/data/{COUNTRY}/geo_baseline_{date}.json`:

```json
{
  "pulled_at": "2026-05-27T12:00:00Z",
  "country": "NL",
  "our_domain": "iptvhelder.nl",
  "queries_tested": 50,
  "raw_results": [
    {
      "keyword": "iptv abonnement",
      "volume": 2900,
      "llm_responses": {
        "chatgpt": {
          "we_were_cited": false,
          "competitors_cited": ["iptvsnederland.com"],
          "top_cited_domain": "iptvsnederland.com",
          "answer_excerpt": "..."
        },
        "claude": { ... },
        "perplexity": { ... },
        "gemini": { ... }
      }
    }
  ],
  "summary": {
    "share_of_voice": {
      "chatgpt": 0.0,
      "claude": 4.0,
      "perplexity": 12.0,
      "gemini": 0.0
    },
    "avg_mention_position_when_cited": null,
    "total_competitor_citations": 87,
    "total_our_citations": 8,
    "top_cited_domains_overall": [
      ["iptvsnederland.com", 34],
      ["deiptv.nl", 21],
      ["iptvhelder.nl", 8]
    ]
  }
}
```

### 6. Git commit + tag
```bash
cd ~/.claude/skills/seo-data-store
git add data/{COUNTRY}/geo_baseline_*.json
git commit -m "data({COUNTRY}): GEO baseline snapshot $(date -u +%Y-%m-%d)"
git tag {cc-lower}-geo-baseline-$(date -u +%Y-%m)
git push origin main {cc-lower}-geo-baseline-$(date -u +%Y-%m)
```

### 7. Print summary

```
✓ GEO baseline captured for NL

Share of voice across 50 commercial-intent queries:
  ChatGPT:    0.0%   (0 / 50 citations — never mentioned)
  Claude:     4.0%   (2 / 50)
  Perplexity: 12.0%  (6 / 50)  ← strongest LLM channel
  Gemini:     0.0%   (0 / 50)

  Overall:    4.0%   (8 / 200 LLM-query pairs)

Top cited domains in this niche (across all LLMs):
  1. iptvsnederland.com (34 citations) ← top competitor
  2. deiptv.nl (21)
  3. iptvhelder.nl (8) — YOU
  4. premiumiptv.nl (6)

Saved: data/NL/geo_baseline_{date}.json
Tagged: nl-geo-baseline-{YYYY-MM}

Re-run in 60 days to measure progress.

Suggested follow-ups:
- Look at iptvsnederland.com's top-cited pages — what do they have that you don't?
- The 50 PAA questions in data/NL/paa_questions_*.json are the LLM-favorite content format
- Add E-E-A-T signals (author bios, citations to authoritative sources) to pages losing the citation battle
```

## Hard rules

- **Never call Semrush** for this command — DataForSEO has the unique LLM tools, Semrush doesn't
- **Don't query more than 50 keywords per run** — DataForSEO LLM API isn't free, and 50 is enough for a representative baseline
- **Always commit the raw_results array** — months later you'll want to see the actual answers, not just summary stats
- **Re-run quarterly, not weekly** — LLM citations don't change daily, and queries cost money
