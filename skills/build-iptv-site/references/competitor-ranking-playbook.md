# Competitor Ranking Playbook (IPTV)

The reusable pattern library behind Stage 4 of `workflows/02_competitor_analysis.md`. Derived from teardowns of real ranking IPTV competitors (first captured in the DE / IPTV Klar launch, 5 competitors / 13 ranking pages). Read this before interpreting `ranking_factors.json` / writing `ranking_playbook.md` for a new market.

## The core lesson

A positioning teardown tells you what to **say**. It does not tell you what **ranks**. When you scrape competitors' *actual ranking URLs* (not their homepages), IPTV rankings consistently come from two levers — and **on-page micro-structure is usually NOT one of them**, because a well-built Astro site already meets/beats competitors there:

1. **Content-cluster breadth** — a library of app/device how-to guides targeting low-KD long-tail. This is the lever a fresh site is missing.
2. **Off-page authority** (backlinks) — not measured by the on-page scrape; almost always the real #1 driver. Always follow Stage 4 with `/iptv-backlink-prospects {cc}`.

So Stage 4's job: confirm we **match** the structural norm (cheap), identify the **cluster gap** to fill (the real on-site lever), and list **weaknesses** to exploit.

## The two ranking playbooks (markets reward one or both)

### Playbook A — "one fat money page"
A single `/iptv-kaufen/` (or homepage) ranks for 30–70 keywords by covering the whole commercial cluster on one URL: pricing table + content categories + sport + 3-step how-it-works + FAQ + reviews + "why us / benefits". A well-structured Astro money page already does this — verify ours matches, don't over-invest.

### Playbook B — "content engine of how-to/app guides"  ← the usual gap
A library of guide pages owning the low-KD long-tail. Observed winning pattern per guide:
- **App/device-specific topic** (TiviMate, IBO Player, IPTV Smarters, Fire TV, Smart TV, M3U playlist) — many at KD 2–13, the easiest wins on the board.
- **Year in the title** ("… 2026") + **fresh `dateModified`** (updated monthly/quarterly).
- **`HowTo` or `Article` schema + `FAQPage`**, 5–10 FAQ Q&As each.
- **1,500–2,200 words**, numbered step outlines, an explicit "Rechtliche Hinweise / legal & safety" E-E-A-T section.
- Internal links back to the money page + related guides.

A new site has **zero** of these. This cluster is the highest-ROI on-site work after launch.

## The on-page structural norm (what to match-or-beat)

Targets, expressed relative to the scraped competitor set (`ranking_factors.json.norm`):

| Signal | Target |
|---|---|
| Primary keyword in `<title>` | always |
| `<title>` ≈ `<h1>` | yes |
| JSON-LD schema set | **beat** the market: emit WebSite + Organization + Product + FAQPage + BreadcrumbList (most competitors ship only 2 types) |
| Word count | ≥ norm median; aim for norm p75 |
| FAQ Q&As w/ FAQPage schema | ≥ norm median (typ. 5–10) |
| Internal links/page | ≥ norm median (a clean Astro build easily exceeds this) |
| `og:locale` + `<html lang>` | correct target locale (see Exploit #1 — competitors frequently get this wrong) |
| Device/install pages | use `HowTo` schema (competitors use it for these; an `ItemList` is weaker here) |

If our generated page already exceeds the norm on every row, **do not** spend more on on-page — move budget to the cluster gap + backlinks.

## Recurring competitor weaknesses to exploit

1. **Locale misconfiguration** — WordPress/Elementor IPTV sites very often ship `og:locale=en_US` / `en_GB` on a non-English site. Free win: we emit the correct locale fleet-wide.
2. **Thin schema on content leaders** — the site that owns the guide cluster often has only `WebPage` schema on its hub/home. Out-schema it.
3. **No BreadcrumbList anywhere** — common. We emit it fleet-wide.
4. **Money pages with no FAQ section** — some rank without one; we add FAQ + FAQPage and out-cover.
5. **Stale `dateModified`** (>6 months) + thin word count + keyword-stuffed headings — beatable on freshness + depth + clean semantics.

## How this routes into the pipeline

- **03 intent-mapping** reads `content_clusters` → adds the missing guide pages to `blog_backlog` (so `/iptv-new` auto-plans them).
- **05 tech-builder** reads `norm` → emits the competitor-beating schema set + hits word/heading/FAQ targets.
- **04 writer** reads `weaknesses` + the cluster briefs → out-covers competitors explicitly.
- **07 auditor** reads `norm` → competitive gate (warn if below market median for the page's target keyword).

## Honest caveats

- On-page is table-stakes, not the differentiator — don't let a green `ranking_factors` norm create false confidence. The cluster gap + backlinks are where ranking is won.
- The scrape is a snapshot; competitor SERP positions drift. Re-run Stage 4 on a refresh cadence (quarterly) or when a competitor visibly rebrands.
- KD on long-tail app/device terms is low *because* volume is modest — value is in the aggregate of many low-KD guides, not any single one.
