---
description: Build a backlink prospect list for a country site from cached competitor backlink data. Usage:/iptv-backlink-prospects {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. NL, DE)"
---

# /iptv-backlink-prospects {country}

Generate a personalized backlink outreach prospect list for `{country}`. Reads competitor backlink data already in `seo-data-store/data/{COUNTRY}/`, finds high-quality domains linking to ≥2 competitors but NOT to your site, enriches each with contact info via Firecrawl, drafts outreach via Perplexity.

**Touches Semrush API: NO.** Reads cached JSON.

## What to do

### 1. Validate
- Argument required: ISO-3166 alpha-2 (e.g. `NL`).
- Verify `~/.claude/skills/seo-data-store/data/{COUNTRY}/` has at least 2 `backlinks_*.json` files. If not, error: "Run `/iptv-seo-ingest-{cc}` first (or pull Semrush backlinks for ≥2 competitors)."

### 2. Build the prospect set
For each `backlinks_{competitor}_*.json` file (latest date per competitor):
- Read the `referring_domains` array
- For each referring domain entry: extract `domain`, `authority_score`, `backlinks`, `first_seen`

Build a dict `domain → { competitors_linking_to_it: [], total_links: int, max_as: int }`.

Filter rules (in order):
1. **AS ≥ 25** (Semrush authority score — drops spam by default)
2. **Domain appears in ≥ 2 competitor backlinks** (intersection signal — these are domains willing to link to "IPTV sites in NL")
3. **Domain is NOT in our backlinks** (read `backlinks_iptvhelder_*.json` if exists)
4. **Drop spam patterns**: `*.blogspot.*`, `*.tumblr.*`, `*.wordpress.com`, `*.wixsite.*`, `linkfarm`, `linkdir`, `seo-dir`, TLDs `.top .click .loan .stream .date`
5. **Cap at 50 prospects** sorted by: `competitor_count desc`, then `max_as desc`, then `total_links desc`

### 3. Enrich top-50 with contact info (Firecrawl)
For each prospect, call `mcp__firecrawl__firecrawl_scrape` on `https://{domain}/`:
- Extract: page title, meta description, any `mailto:` links on homepage, any `/contact` or `/about` link
- If a `/contact` link exists, scrape that too and extract email addresses + contact form URL
- If no email found, mark `contact_method: "form"` with the URL of the contact page

Rate limit: 1 prospect every 2 seconds (Firecrawl free tier). Total ~100 seconds for 50 prospects.

### 4. Draft outreach emails (Perplexity)
For each top-20 prospect (skip the rest for now — manual outreach is time-bound), call `mcp__perplexity__perplexity_ask` with a prompt template:

```
You're drafting a backlink outreach email for IPTV Helder (iptvhelder.nl), a Dutch IPTV subscription service.

The recipient site is: {prospect_domain}
Site's apparent topic: {prospect_meta_description}
They already link to these competitors of mine: {competitors_linked_to}

Write a SHORT, personalized outreach email (under 120 words) that:
1. Compliments something specific about THEIR site (don't be generic)
2. Mentions one of our specific USPs: Nederlandse klantenservice 7 dagen per week, iDEAL betaling, 24-uurs gratis test
3. Suggests a non-pushy reason they might link to us (resource page mention, comparison addition, guest post)
4. Ends with a low-friction CTA: "Open to a quick reply if interested?"

Output language: English (most international SEO sites prefer EN even for NL-focused content).
Tone: peer-to-peer, NOT salesy. Imagine you're emailing a fellow blogger.

Output format:
Subject: {subject line}
Body: {email body}
```

### 5. Output CSV
Write to `~/Code/iptv-fleet/sites/nl/.tmp/backlink-prospects-{date}.csv` with columns:

```
rank,domain,authority_score,links_to_competitors,total_competitor_backlinks,contact_email,contact_url,draft_subject,draft_body,status,sent_date,response_date,outcome
```

- Top 20 prospects: full enrichment + draft
- Prospects 21-50: enrichment + empty draft (user can run with `--all` later to backfill)
- `status` defaults to `"pending"` — user updates as they send

### 6. Print summary

```
✓ Backlink prospect list generated: ~/Code/iptv-fleet/sites/nl/.tmp/backlink-prospects-{date}.csv

50 prospects total | 20 with full email drafts | 30 awaiting drafts

Top 5 prospects by competitor-count + AS:
1. example-nl-tech.nl (AS 58, 4 competitors link) — email: editor@example-nl-tech.nl
2. ...

Suggested workflow:
- Open the CSV in Numbers/Excel/Sheets
- Review the 20 drafted emails
- Send 5-10 per day. Personalize the {placeholder} bits.
- Update the status column as you send
- Goal: 60 emails sent over 4-5 days, expect 5-15% reply rate
```

## Hard rules

- **Never email anyone directly** — this command produces drafts only, user sends manually
- **Respect the spam filter list** — never include `.blogspot.*` or `linkdir.*` domains even if they have high AS
- **Cap Firecrawl at 50 prospects per run** — costs add up fast
- **Cap Perplexity drafts at 20 per run** — quality > quantity for outreach
- **Cite which competitors link to the prospect** in the draft — gives Claude/user context for personalization
