# Workflow: IPTV Keyword Research (DataForSEO)

**Goal:** Produce a ranked, deduplicated keyword universe for a specific `target_country` + `target_language`, saved to `.tmp/{country}_{lang}/keywords.json`, ready to feed intent mapping.

---

## Required Inputs
- `target_country` (ISO 3166-1 alpha-2, e.g. `US`, `FR`)
- `target_language` (ISO 639-1)
- `brand_name` (for branded keyword expansion)

---

## Seed Keywords (IPTV niche)

Translate these seeds into `target_language` before querying. Do NOT query English seeds against a non-English market — volumes will be wrong.

**Core commercial intent:**
- `iptv subscription`
- `buy iptv`
- `iptv service`
- `best iptv provider`
- `iptv {country_name}`
- `cheap iptv`
- `premium iptv`
- `iptv 4k`
- `iptv trial` / `iptv free trial`
- `iptv 12 months`

**Device intent:**
- `iptv firestick`
- `iptv android`
- `iptv smart tv`
- `iptv samsung / lg`
- `iptv mag box`
- `iptv iphone`
- `iptv formuler`

**Channel/content intent (country-specific):**
- `iptv sports` → expand with local leagues (e.g. `iptv premier league`, `iptv ligue 1`, `iptv bundesliga`, `iptv nfl`)
- `iptv ppv`
- `iptv movies` / `vod iptv`
- `iptv live tv {country}`
- `{local broadcaster name} iptv` (e.g. `bein iptv`, `sky iptv`, `canal+ iptv`)

**Informational (blog fuel):**
- `how to install iptv on firestick`
- `what is iptv`
- `iptv vs cable`
- `is iptv legal in {country}`
- `best iptv player`

**Branded:**
- `{brand_name}`
- `{brand_name} review`
- `{brand_name} login`

---

## Procedure

### Step 1 — Resolve DataForSEO location code
Use the DataForSEO Labs `locations` endpoint to get the numeric `location_code` for `target_country`. Cache result.

### Step 2 — Seed expansion
For each seed keyword, call:
```
POST /v3/dataforseo_labs/google/keyword_ideas/live
{
  "keywords": [<seeds>],
  "location_code": <code>,
  "language_code": "{target_language}",
  "limit": 1000,
  "include_serp_info": true,
  "filters": [["keyword_info.search_volume", ">", 50]]
}
```

### Step 3 — Pull SERPs for top commercial intent terms
For the top 30 commercial intent keywords (buy/subscription/trial/price), call:
```
POST /v3/serp/google/organic/live/advanced
```
Store top 10 ranking URLs, titles, descriptions per keyword. These feed the competitor analysis workflow.

### Step 4 — Pull keyword difficulty
For the full expanded list, batch through:
```
POST /v3/dataforseo_labs/google/bulk_keyword_difficulty/live
```

### Step 5 — Related keywords (question mining)
For the top 10 informational seeds, call:
```
POST /v3/dataforseo_labs/google/related_keywords/live
```
Collect "People Also Ask" and long-tail question phrases — these become FAQ + blog fodder.

### Step 6 — Deduplicate + normalize
- Lowercase, strip punctuation
- Remove exact duplicates
- Merge near-duplicates (Levenshtein distance ≤ 2 with same intent)
- Drop anything with `search_volume < 50` (country-adjusted — lower threshold for small markets: 20 for countries with population < 10M)

### Step 7 — Score
Composite score per keyword:
```
score = (search_volume * commercial_weight) / max(keyword_difficulty, 1)
```
Where `commercial_weight`:
- buy/subscription/price/trial/cheap/premium → 3.0
- device-specific → 2.0
- channel/sport-specific → 1.5
- informational → 1.0
- branded → 2.5

### Step 8 — Save
Write to `.tmp/{country}_{lang}/keywords.json`:
```json
{
  "country": "FR",
  "language": "fr",
  "generated_at": "ISO-8601",
  "dataforseo_location_code": 2250,
  "seeds_used": [...],
  "keywords": [
    {
      "keyword": "abonnement iptv",
      "search_volume": 12000,
      "keyword_difficulty": 38,
      "cpc": 2.10,
      "intent": "commercial",
      "score": 946.0,
      "serp_top_10": ["url1", "url2", ...]
    }
  ]
}
```

---

## Tool Reference
`tools/dataforseo_keyword_research.py` — implements steps 1–8 end to end. Takes `--country`, `--language`, `--brand` flags. Reads `DATAFORSEO_LOGIN` and `DATAFORSEO_PASSWORD` from `.env`.

---

## Learned Constraints (update as you discover them)

- DataForSEO `keyword_ideas` caps at 1000 results per call — batch seeds, don't pass all at once.
- Some small-country language combinations (e.g. `ar_MA`) return zero SERP data. Fall back to the next-broadest language code (`ar`) and flag the gap in the report.
- IPTV keywords are often flagged as "adult/restricted" in some DataForSEO categories — use `include_adult_keywords: true` when applicable.
- Volumes are 30-day smoothed — sports-season keywords (e.g. `iptv premier league`) under-report in summer. If research runs in off-season, multiply sports keyword volumes by 1.5× and flag as `seasonal_adjusted: true`.

---

## Output Handoff
Pass `.tmp/{country}_{lang}/keywords.json` + `.tmp/{country}_{lang}/serps.json` to `02_competitor_analysis.md`.
