---
description: Parse manually-exported Semrush CSVs in seo-data-store/data/NL/raw/ into typed JSON. Burns 0 Semrush units.
---

# /iptv-seo-ingest-nl

Ingest the user's manually-exported Semrush UI CSVs for the Netherlands market. Convert to typed JSON, build a manifest, commit + tag, and print a summary.

**Touches Semrush API: NO.** Reads CSVs the user already exported.

## What to do

### 1. Pre-flight
- Confirm `~/.claude/skills/seo-data-store/data/NL/raw/` exists and has CSV files. If not, tell the user:
  > "No CSVs found. Follow `~/.claude/skills/seo-data-store/docs/manual-extraction-guide-nl.md` to export from Semrush UI first."
- List the CSV files there. Show the user what was found (filename → looks like {kind} report).
- Confirm `iptvhelder.nl` is the our_domain. Read `~/Code/iptv-fleet/fleet.config.yaml` for the NL `competitors[]` list. If missing, ask via `AskUserQuestion` for the 5 competitor domains.

### 2. Dry run first
Run the parser in dry-run mode to validate everything without writing JSON:

```bash
python3 ~/.claude/skills/seo-data-store/scripts/ingest_csvs.py NL \
    --our-domain iptvhelder.nl \
    --competitors {competitor1} {competitor2} ... \
    --dry-run
```

Show the user the dry-run output. If any CSV failed to parse or had unexpected columns, **stop and ask the user** which one to skip or fix. Common issues:
- CSV uses `;` instead of `,` (Semrush in some EU locales) — parser handles automatically
- Column missing → Semrush trial might have hidden some columns. Tell user which column is missing and what report needs re-export.

### 3. Real run
If dry run looks clean:

```bash
python3 ~/.claude/skills/seo-data-store/scripts/ingest_csvs.py NL \
    --our-domain iptvhelder.nl \
    --competitors {competitor1} {competitor2} {competitor3} {competitor4} {competitor5}
```

The parser writes:
- One parsed JSON next to each raw CSV (for organic, backlinks, positions, domain_overview, paa_questions)
- Aggregated JSON for multi-file reports:
  - `keywords_YYYY-MM-DD.json` (merged from all `keyword_magic_nl_*.csv`)
  - `keyword_gap_YYYY-MM-DD.json` (combined missing + weak)
  - `topic_briefs_YYYY-MM-DD.json` (merged from all `topic_research_*.csv`)
- The manifest: `nl_manual_extraction_manifest_YYYY-MM-DD.json`
- Updated `latest.json` pointer with `mode: manual-ingest` and `freeze_tag`

### 4. Quality checks
Read the manifest and verify:
- All expected file kinds present: keyword_magic (aggregated), keyword_gap, positions, organic (×5), backlinks (×5), topic_briefs, domain_overview, paa_questions
- `keywords_*.json` has ≥ 200 unique keywords. If less, warn user.
- `keyword_gap_*.json` has ≥ 100 gaps. If less, warn user.
- `paa_questions_*.json` has ≥ 50 questions. If less, warn user.

### 5. Commit + tag + push
```bash
cd ~/.claude/skills/seo-data-store
git add data/NL/raw/ data/NL/*.json
git commit -m "data(NL): manual Semrush extraction $(date -u +%Y-%m-%d)

CSVs ingested: $(ls data/NL/raw/*.csv | wc -l | xargs)
JSON files written: $(ls data/NL/*.json | wc -l | xargs)
Frozen tag: nl-semrush-manual-$(date -u +%Y-%m)"

git tag nl-semrush-manual-$(date -u +%Y-%m)
git branch frozen/nl-$(date -u +%Y-%m)
git push origin main nl-semrush-manual-$(date -u +%Y-%m) frozen/nl-$(date -u +%Y-%m)
```

### 6. Print summary
Show the user:

- **Total CSVs ingested**: N files
- **Top 20 opportunity keywords** (read `keyword_gap_*.json`, sort by opportunity_score, show: keyword | volume | KD | competitor_count | score)
- **Top 50 backlink prospect candidates** — compute inline:
  ```python
  # Union of referring_domains from all backlinks_*.json
  # Minus referring_domains in backlinks_iptvhelder.nl_*.json (if we have it)
  # Filter: AS ≥ 25, appears in ≥ 2 competitors
  # Sort by competitor_count desc, then AS desc
  ```
- **Top 30 PAA questions** (highest-volume keywords, deduped)
- **Domain authority comparison** (parse `domain_overview_*.json`, show ranked table)

### 7. Next steps
Tell the user:
```
✓ NL Semrush data archived to git tag `nl-semrush-manual-{date}`

Next steps:
- /iptv-backlink-prospects NL    — enrich the prospect list with contact info + outreach drafts
- /iptv-geo-baseline NL          — snapshot LLM citation state (DataForSEO)
- Then: writer agent generates pillar content from the frozen JSONs
```

## Hard rules

- **Never call Semrush MCP from this command.** This command is for manual-ingest mode only.
- **Always run --dry-run first** so the user can spot issues before files are committed.
- **Never overwrite frozen tagged files.** If `freeze_tag` is already set in `latest.json` for the same date, abort and ask user.
- **Always commit raw CSVs alongside parsed JSON.** Raw CSVs are the audit trail proving the JSON came from real Semrush data on a specific date.
