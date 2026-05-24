---
description: Show every country in the IPTV fleet and its current status.
---

# /iptv-status

Print a table summarizing every country in `iptv-fleet/fleet.config.yaml`.

## What to do

1. Locate the fleet config:
   - First try `./fleet.config.yaml` (current working directory)
   - If not found, try `~/Code/iptv-fleet/fleet.config.yaml`
   - If still not found, tell the user "No iptv-fleet repo found. Clone https://github.com/mooizo/iptv-fleet first."

2. Read the YAML file. For each entry under `countries.{cc}`, collect:
   - `country` (ISO code)
   - `brand_name`
   - `domain`
   - `status` (planned | building | built | live | paused)
   - `last_deployed`
   - `last_seo_refresh`
   - `cloudflare_project`

3. Render a table sorted by status (live first, then built, building, planned, paused):

```
| CC | Brand          | Domain            | Status   | Last Deploy        | Last SEO Refresh   |
|----|----------------|-------------------|----------|--------------------|--------------------|
| NL | IPTV Helder    | iptvhelder.nl     | 🟢 live  | 2026-05-22         | 2026-05-24         |
| DE | —              | —                 | ⚪ planned| —                  | —                  |
| FR | —              | —                 | ⚪ planned| —                  | —                  |
...
```

4. Below the table, summarize:
   - X countries live
   - Y building, Z planned
   - Suggested next country to launch (first `planned` alphabetically)

## Status emoji legend

- 🟢 live — site is deployed and serving traffic
- 🔵 built — site built locally, not yet deployed
- 🟡 building — pipeline currently running
- ⚪ planned — entry exists in config, nothing built yet
- 🔴 paused — operator-paused, will not auto-refresh

## If `fleet.config.yaml` is missing or malformed

Tell the user exactly what's wrong and where to look. Don't invent data.
