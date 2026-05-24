# IPTV Seed Keywords

Canonical seed list for step 01 (DataForSEO keyword research). **Always translate into `target_language` before querying** — English seeds against non-English markets return inflated and wrong volumes.

## 7 intent buckets + commercial weight multipliers

Composite score formula used by `tools/dataforseo_keyword_research.py`:

```
score = (search_volume × commercial_weight) / max(keyword_difficulty, 1)
```

| Bucket | Weight | Rationale |
|---|---|---|
| **Commercial** (buy/subscription/price/trial/cheap/premium) | **3.0** | Highest conversion intent |
| **Branded** (brand_name + variants) | **2.5** | High intent + low KD |
| **Device** (firestick/android/smart-tv/etc) | **2.0** | Medium commercial + clear buy journey |
| **Content** (sports/channels/PPV/movies) | **1.5** | Conversion varies by niche |
| **Informational** (what is/how to/legal) | **1.0** | Blog fuel, low direct conversion |

## Core commercial intent seeds

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
- `iptv 6 months`
- `iptv monthly`

## Device intent seeds

- `iptv firestick`
- `iptv android`
- `iptv android tv`
- `iptv smart tv`
- `iptv samsung`
- `iptv lg`
- `iptv apple tv`
- `iptv iphone`
- `iptv ios`
- `iptv mag box`
- `iptv formuler`

## Channel / content intent seeds (country-specific)

Expand these with local league names:
- `iptv sports` → `iptv premier league`, `iptv bundesliga`, `iptv ligue 1`, `iptv la liga`, `iptv serie a`, `iptv eredivisie`, `iptv nfl`, `iptv nba`
- `iptv ppv`
- `iptv ufc`
- `iptv formula 1` / `iptv f1`
- `iptv champions league`
- `iptv movies` / `vod iptv`
- `iptv live tv {country}`
- `{local broadcaster} iptv` → e.g. `bein iptv`, `sky iptv`, `canal+ iptv`, `dazn iptv`, `ziggo iptv`

## Informational seeds (blog fuel)

- `how to install iptv on firestick`
- `how to install iptv on android tv`
- `what is iptv`
- `how does iptv work`
- `iptv vs cable`
- `iptv vs streaming`
- `is iptv legal in {country}`
- `best iptv player`
- `m3u playlist`
- `iptv buffering fix`

## Branded seeds

- `{brand_name}`
- `{brand_name} review`
- `{brand_name} login`
- `{brand_name} app`
- `{brand_name} pricing`

## Seasonal adjustment

DataForSEO volumes are 30-day smoothed — **sports-season keywords under-report in summer**. If research runs in off-season (June–August for European football, February–August for NFL), multiply sports keyword volumes by **1.5×** and flag as `seasonal_adjusted: true` in the output JSON.

## Filtering rules

- Drop keywords with `search_volume < 50` (use `< 20` for countries with population < 10M)
- Deduplicate near-duplicates (Levenshtein ≤ 2 with same intent bucket)
- Include `include_adult_keywords: true` in DataForSEO call — IPTV sometimes flagged as restricted

## Location codes

Call DataForSEO Labs `locations` endpoint once per country, cache the numeric `location_code`. Common codes:
- NL = 2528, DE = 2276, FR = 2250, ES = 2724, IT = 2380, BE = 2056, UK = 2826, US = 2840, PT = 2620, PL = 2616
