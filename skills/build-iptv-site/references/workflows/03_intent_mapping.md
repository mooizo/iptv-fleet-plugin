# Workflow: Intent Clustering & Page Mapping

**Goal:** Convert the keyword universe into a concrete sitemap where every target keyword has exactly one canonical page owning it. Output: `.tmp/{country}_{lang}/page_map.json` — the contract for the content writer.

---

## Required Inputs
- `.tmp/{country}_{lang}/keywords.json` (from workflow 01)
- `.tmp/{country}_{lang}/gap_analysis.md` (from workflow 02)

---

## Step 1 — Assign intent to every keyword

For each keyword, assign exactly one intent label:

| Intent | Signal phrases | Example |
|---|---|---|
| `transactional` | buy, order, subscription, cheap, price, trial, 12 months, pay | `buy iptv 12 months` |
| `commercial` | best, top, review, vs, comparison, premium, provider | `best iptv provider uk` |
| `navigational` | brand name, brand + login, brand + review | `streamvault login` |
| `informational-device` | how to install, setup, configure, on firestick/android/etc | `how to install iptv on firestick` |
| `informational-content` | what is, is iptv legal, iptv vs cable | `what is iptv` |
| `content-vertical` | specific sport/league/broadcaster + iptv | `iptv premier league` |

Keywords matching multiple labels → pick the one with the highest commercial_weight from workflow 01.

---

## Step 2 — Map intents to pages

Use this mapping table. It is the only allowed page → intent assignment:

| Page | Primary intents | Secondary intents |
|---|---|---|
| `/` (Homepage) | `transactional`, `commercial` | `navigational` |
| `/pricing/` | `transactional` | — |
| `/free-trial/` | `transactional` (trial modifier only) | — |
| `/channels/` | `content-vertical` (generic), `commercial` | — |
| `/devices/` | `informational-device` (index terms) | — |
| `/devices/{device}/` | `informational-device` (device-specific) | `transactional` (device + buy) |
| `/faq/` | `informational-content` (short answers) | — |
| `/blog/{slug}/` | `informational-content` (long-form), `content-vertical` | — |
| `/about/` | `navigational`, trust signals | — |

---

## Step 3 — Assign primary + secondary keywords

Each page must have:
- Exactly **one** primary keyword (highest-score keyword matching that page's intent, not yet taken by another page)
- 3–7 secondary keywords (supporting terms to mention naturally in body copy)
- A clear reason (one line) for the assignment

Rules:
- A keyword can be primary for only one page.
- A keyword can be secondary for multiple pages if intent aligns.
- If a high-volume keyword doesn't fit the canonical page map, create a new `/blog/{slug}/` entry for it.
- Device pages: primary keyword must contain the device name.
- Channel vertical pages (e.g. `/blog/watch-premier-league-iptv/`): only create if volume > 500/mo and gap analysis confirmed competitors don't own it.

---

## Step 4 — Generate blog post targets

From leftover informational and long-tail content keywords:

1. Group by topic using simple keyword overlap (shared noun phrases).
2. Each cluster becomes one blog post.
3. Each blog post targets one primary keyword + 3–5 semantic supporting keywords.
4. Cap blog posts at 15 for launch. The rest go into `.tmp/{country}_{lang}/blog_backlog.json` for phase 2.

Blog post selection priority:
1. Gap analysis "Priority Content Gaps" first
2. Questions from DataForSEO related_keywords (high intent for featured snippets)
3. **Live-research topics from `tools/blog_topic_research.py`** (see below)
4. Device install guides not yet covered as pages
5. Seasonal / event-based topics (only if within 60 days of event)

### Optional: run blog topic research for live demand signal

After producing `page_map.json`, run:

```bash
python tools/blog_topic_research.py --country FR --language fr
```

This uses Perplexity to discover what people in the target country are *currently* asking about IPTV (forums, Reddit, news, search trends in the last 6 months) and Claude to cluster the raw research into 5–15 ranked blog post briefs with:
- Slug, title, primary keyword (in target language)
- H2 outline
- Search intent + target word count
- Angle (why our post wins vs competitors)
- Justification (links back to the research)

Output: `.tmp/{country}_{lang}/blog_topics.json` — merge these briefs into the `blog_backlog` section of `page_map.json` before handing off to the writer.

**Cost per market:** ~$0.03 (1 Perplexity call + 1 Claude call). Worth running for every market at launch + quarterly refreshes.

**When to skip it:** If you're doing a rapid test build or the market is tiny and you already have enough topics from DataForSEO's related_keywords. For serious go-to-market runs, always run it.

---

## Step 5 — Output `page_map.json`

```json
{
  "country": "FR",
  "language": "fr",
  "pages": [
    {
      "path": "/",
      "type": "homepage",
      "primary_keyword": "abonnement iptv",
      "primary_volume": 12000,
      "secondary_keywords": ["iptv france", "iptv 4k", "iptv pas cher"],
      "intent": "transactional",
      "differentiators_to_lead_with": ["99.9% uptime", "24h free trial", "local support in french"],
      "reasoning": "Highest-volume transactional term in market, market has 5 competitors all claiming '20,000+ channels' — we lead with uptime + local support instead"
    },
    {
      "path": "/devices/firestick/",
      "type": "device_install_guide",
      "primary_keyword": "iptv firestick france",
      "...": "..."
    }
  ],
  "blog_backlog": [...]
}
```

---

## Tool Reference
`tools/intent_cluster.py` — implements steps 1–5. Takes keyword + gap files and emits `page_map.json`.

---

## Quality Gate

Before handoff to writer, verify:
- [ ] Every required page (per `00_build_iptv_site.md` architecture) has a primary keyword assigned
- [ ] No keyword is primary for more than one page
- [ ] Homepage primary keyword is the highest-score transactional term
- [ ] At least 5 blog posts are queued (not 15 if market is small — minimum 5)
- [ ] Every "Priority Content Gap" from gap_analysis.md is reflected in the page map

---

## Output Handoff
Pass `.tmp/{country}_{lang}/page_map.json` to `04_write_content.md`.
