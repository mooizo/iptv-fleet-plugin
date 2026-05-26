---
description: Pull current SERP positions for top keywords via DataForSEO. Use daily for ongoing rank tracking. Usage:/iptv-rank-track {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. NL)"
---

# /iptv-rank-track {country}

Pull current SERP rankings for `iptvhelder.nl` (or relevant brand for `{country}`) for the top 100 tracked keywords via DataForSEO. Compare against yesterday's pull, surface gainers/losers, commit to the seo-data-store repo.

**Touches Semrush: NO.** DataForSEO only — cheap, designed for daily polling.

## What to do

### 1. Validate
- Argument: ISO-3166 alpha-2 (e.g. `NL`)
- Verify `~/.claude/skills/seo-data-store/data/{COUNTRY}/position_baseline_*.json` OR `keyword_gap_*.json` exists. If neither, error: "Run `/iptv-seo-ingest-{cc}` first to establish a baseline."
- Read `~/Code/iptv-fleet/fleet.config.yaml` `countries.{cc}.domain` for the brand domain.

### 2. Build the tracked keyword set
Strategy depends on what's available:

**Preferred**: Read `position_baseline_*.json` → take all 100 keywords from there. These are the baseline kws.

**Fallback**: If position_baseline doesn't exist, read `keyword_gap_*.json` top 100 by opportunity_score.

Keep the kw list cached in `~/.claude/skills/seo-data-store/data/{COUNTRY}/.tracked_keywords.json` so subsequent runs use the same set (consistency over time).

### 3. Pull SERP for each keyword
For each tracked keyword, call:

```
mcp__dataforseo__serp_organic_live_advanced
  keyword: "{the_keyword}"
  location_name: "Netherlands"  (or appropriate location for {country})
  language_code: "nl"            (or appropriate)
  device: "desktop"
  depth: 100                     (top 100 SERP results)
```

Parse the response to find:
- Position of `iptvhelder.nl` (or your domain) — `null` if not in top 100
- Top 10 competing domains + their positions + URLs
- SERP features detected (PAA, featured snippet, video, image pack)

Rate limit: ~2 seconds per kw × 100 kws = ~3-4 minutes per run.

### 4. Compute deltas
Read the most recent `rank_track_*.json` (yesterday or last run). For each kw:
- `previous_position`: from prior file (or null if first run)
- `current_position`: from this run
- `delta`: `previous − current` (positive = improved, negative = dropped)

Classify each kw:
- 🟢 **Gainer**: improved 3+ positions OR entered top 10
- 🔴 **Loser**: dropped 3+ positions OR fell out of top 10
- ⚪ **Stable**: ±1-2 positions

### 5. Save
Write to `~/.claude/skills/seo-data-store/data/{COUNTRY}/rank_track_{date}.json`:

```json
{
  "pulled_at": "2026-06-06T07:00:00Z",
  "country": "NL",
  "domain": "iptvhelder.nl",
  "vs_previous": "rank_track_2026-06-05.json",
  "rankings": [
    {
      "keyword": "iptv abonnement",
      "volume": 2900,
      "current_position": 11,
      "previous_position": 14,
      "delta": 3,
      "classification": "gainer",
      "current_url": "https://iptvhelder.nl/abonnement",
      "serp_top10": [
        {"domain": "iptvsnederland.com", "position": 1, "url": "..."}
      ],
      "serp_features": ["paa", "featured_snippet"]
    }
  ],
  "summary": {
    "total_tracked": 100,
    "ranking_in_top_10": 12,
    "ranking_in_top_30": 31,
    "gainers": 8,
    "losers": 3,
    "stable": 89,
    "biggest_gain": {"keyword": "...", "delta": 14},
    "biggest_loss": {"keyword": "...", "delta": -9}
  }
}
```

### 6. Commit (only if movement > threshold)
To avoid spammy commits on quiet days:
- If ≥ 1 keyword moved ≥ 3 positions OR ≥ 5 keywords moved ≥ 1 position → commit + push
- Otherwise just save locally, no git activity

When committing:
```bash
cd ~/.claude/skills/seo-data-store
git add data/{COUNTRY}/rank_track_*.json
git commit -m "rank-track({COUNTRY}): {N} gainers, {M} losers $(date -u +%Y-%m-%d)"
git push
```

### 7. Print summary

```
✓ Rank tracking complete for NL — iptvhelder.nl

Snapshot: rank_track_2026-06-06.json
Comparison: vs rank_track_2026-06-05.json

Ranking distribution:
  Top 10:  12 keywords  (+1 vs yesterday)
  Top 30:  31 keywords  (+2)
  Top 100: 67 keywords  (no change)

🟢 Top 5 GAINERS:
  iptv firestick           14 → 8    (+6)
  iptv 4k                  21 → 17   (+4)
  iptv eredivisie 2026     33 → 28   (+5)
  ...

🔴 Top 3 LOSERS:
  iptv smart tv            9  → 14   (-5)  ← page change needed?
  ...

⚪ 89 keywords stable (±1-2 positions)

Trend over last 7 days: average position improved by 1.8 (was 28.3 → now 26.5) 📈
```

### 8. First-run scheduling
If this is the user's first run (no `rank_track_*` files exist yet), after the run prompt:

```
This is your first rank tracking run. To automate daily tracking, run:

mcp__scheduled-tasks__create_scheduled_task with:
  name: "iptv-rank-track-{cc-lower}"
  command: "claude --prompt '/iptv-rank-track {COUNTRY}'"
  cron: "0 7 * * *"     # daily at 7am UTC

Want me to set this up? (y/n)
```

## Hard rules

- **Never call Semrush MCP from this command** — DataForSEO is ~3× cheaper for SERP positions at this scale
- **Always use the same tracked keyword set** — switching the kw list breaks delta tracking
- **Don't commit on quiet days** — keeps git history readable
- **Cap at 100 keywords** — more is overkill; the top 100 by volume capture 80%+ of traffic
- **Cache the SERP response for 24 hours** — if user re-runs same day, return cached (DfS bills per call)
