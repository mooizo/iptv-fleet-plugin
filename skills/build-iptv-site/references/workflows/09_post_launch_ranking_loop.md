# Workflow 09 — Post-Launch Ranking Loop

**Goal:** Continuously improve a deployed IPTV country site's organic positions by detecting decay, surfacing quick wins, refreshing keyword data, and feeding the next content/optimization cycle. **Runs monthly per active country.**

**Status:** Standing workflow. Once a site is deployed via workflow `08_deploy_cloudflare.md`, this workflow runs on a calendar cadence (recommended: first weekday of each month).

**Prerequisite:** Site is deployed, verified in Google Search Console, and at least 30 days of GSC data exists.

**Budget governance:** Read `references/semrush_budget_rules.md` BEFORE executing. Target spend per country per month: **~100 API units**. Most of this loop is **free** (GSC + SEMrush non-API quotas).

---

## Required inputs

| Input | Source |
|---|---|
| `cc`, `lang` | from earlier workflows |
| `domain` | the live deployed domain (e.g. `vikingstream.tv`) |
| `gsc_property` | the GSC-verified property URL |
| `semrush_project_id` | optional — if a SEMrush Position Tracking project exists, its ID |

---

## The 6 monthly checks

### 1. Traffic Drops (GSC — free)

**`mcp__gsc__traffic_drops`** for `{gsc_property}` over the last 28 days vs prior 28 days.

- Flag pages with **clicks down >20% MoM**.
- For each flagged page, note the queries driving the loss.

Output: `.tmp/{cc}_{lang}/ranking_loops/{YYYY-MM}/01_traffic_drops.json`.

---

### 2. Quick Wins (GSC — free)

**`mcp__gsc__quick_wins`** for `{gsc_property}`.

Returns keywords ranking **position 8–20** (page 2 / bottom of page 1) where small CTR boosts or content improvements compound.

- Sort by impressions × (10 - current_position) to prioritize.
- Take top 10 → these become this month's optimization targets.

Output: `.tmp/{cc}_{lang}/ranking_loops/{YYYY-MM}/02_quick_wins.json`.

---

### 3. Cannibalization Check (GSC — free)

**`mcp__gsc__cannibalization_check`** for `{gsc_property}`.

Identifies keywords where 2+ pages on our domain compete against each other (one wins, the other dilutes). For each match:

- Decide: consolidate (301 redirect the loser into the winner) or differentiate (rewrite the loser's intent).
- Add the decision to next month's content backlog.

Output: `.tmp/{cc}_{lang}/ranking_loops/{YYYY-MM}/03_cannibalization.json`.

---

### 4. SEMrush Position Tracking refresh (FREE — bills against Keywords quota, not API units)

If `semrush_project_id` is set:

**`mcp__semrush__execute_report(report='projects_position_tracking', params={project_id, display_limit: 50})`** — billed against the 1,500/mo Keywords quota.

Captures daily-resolution position movement for the top 50 tracked keywords. Compare to last month's snapshot:

- New top-10 entries → celebrate, lock in content.
- Drops out of top-20 → investigate (content stale? competitor passed us? algorithm shift?).

Output: `.tmp/{cc}_{lang}/ranking_loops/{YYYY-MM}/04_position_tracking.csv`.

If no SEMrush project exists yet, **set one up via the SEMrush web UI** the first time this workflow runs (one-time setup, free under the subscription).

---

### 5. Targeted SEMrush re-pull for decaying keywords (API units, capped)

For any keyword GSC flagged as decaying in step 1 (max 10 keywords):

**`mcp__semrush__execute_report(report='phrase_this', params={phrase: kw, database: cc})`** — 10u per keyword.

**Hard cap:** **10 keywords × 10u = 100u/month.** If decay list is longer, only re-pull the top 10 by impressions.

Compare SEMrush metrics to last month's snapshot in `.tmp/{cc}_{lang}/semrush/02a_phrase_these.csv`:

- If SV dropped > 30% → the query itself is dying, not our content. De-prioritize.
- If SV stable but our position dropped → our content needs work.
- If competition score increased → new entrants are bidding/ranking; competitor scan next quarter.

Output: `.tmp/{cc}_{lang}/ranking_loops/{YYYY-MM}/05_decay_repull.csv`.

---

### 6. Content Recommendations (GSC + Perplexity — free)

**`mcp__gsc__content_recommendations`** for `{gsc_property}` over last 90 days.

For each top recommendation (max 3):

- Optionally enrich with **`mcp__perplexity__perplexity_ask`** asking what's currently trending around the topic in the target market.
- Add to the next month's content backlog.

Output: `.tmp/{cc}_{lang}/ranking_loops/{YYYY-MM}/06_content_recs.md`.

---

## Monthly summary — `ranking_dashboard.md` (append-only)

After all 6 checks complete, append a section to `.tmp/{cc}_{lang}/ranking_dashboard.md`:

```markdown
## {YYYY-MM-DD} snapshot

**Headline metrics**
- Total clicks (28d): {N} ({+/-X%} MoM)
- Total impressions (28d): {N} ({+/-X%} MoM)
- Avg position: {X.X} ({+/-X.X} MoM)
- Top-10 keywords: {N}
- Keywords ranking page 2: {N}

**This month's work**
- Optimize: {top 3 quick-win pages}
- Fix: {top 3 traffic drops}
- Decide: {cannibalization actions}
- Write: {top 3 content recommendations}

**Budget consumed this loop**
- SEMrush API units: {N}u (target ≤ 100)
- GSC calls: {N} (free)
- Cumulative units since launch: {N}u
```

---

## Hand-off

The monthly outputs become inputs for:

- **Step 04 (`04_write_content.md`)** — for new content backlog items.
- **Manual on-page edits** — for the optimize-existing-page tasks. Use the project's existing edit workflow (e.g. `viking-iptv`'s `conversion-loop` for surgical edits).
- **Step 02 (`02_competitor_analysis.md`)** — if competitor pressure spiked, re-run for top-3 competitors next quarter (per `semrush_budget_rules.md` cadence).

---

## Calendar cadence

| Cadence | What runs |
|---|---|
| **Monthly** | All 6 checks above. ~100u + free. |
| **Quarterly** | Re-run workflow 01a Phase 3 (competitor extraction) — tier-2 mode, ~300u. |
| **Annually** | Re-run workflow 01a Phase 2 lead-market (related + KDI), ~2,800u. Only once a year per region. |
| **One-off** | Triggered by a position-tracking spike or drop — investigate immediately. |

---

## Automation note

This workflow is currently **manual** — the user (or an agent operating on their behalf) runs it monthly. The next infrastructure step is a project-scoped `ranking-loop` sub-agent (analog of the existing `conversion-loop` agent at `viking-iptv/.claude/agents/conversion-loop.md`) that executes all 6 checks unattended and writes the monthly summary. **Out of scope for this workflow file** — declared here so the path forward is clear.
