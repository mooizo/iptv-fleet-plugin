# SEO Pillars — the governing framework for every IPTV site

This is the **apex SEO reference** for the fleet. Every IPTV site we build and optimize is measured against these pillars: **Technical SEO · Content · On-Page SEO · Off-Page SEO**, plus **GEO** (Generative Engine Optimization) — AI-search citation is now a first-class surface, so it's tracked as a 5th pillar.

This doc is the framework; the per-pillar execution detail lives in the references/workflows/tools it points to. It is grounded in 2026 SEO deep-research (cited at the bottom) and in what we actually validated building NL (aurora) + DE (monolith). It does **not** restate the audit checklist or the ranking playbook — it frames them.

> **How to use this:** at the start of any build, read this doc first. Each page, piece of content, and off-site action should be traceable to one of these pillars. The "Open edge" lines are the known gaps — close them as you build, don't ignore them.

---

## 1. Technical SEO
*Crawlability, indexability, performance, and the locked SEO engine.*

**2026 reality.** **INP < 200ms** is now the interaction metric (replaced FID); with **LCP < 2.5s** and **CLS < 0.15** it's a hygiene bar in saturated niches, and AI crawlers are latency-sensitive (slow sites get cited less). AI crawlers often **don't execute JS** → critical content (plans, prices, FAQ) must be in the initial **server-rendered HTML**. Helpful-content folded into core causes **section-level demotion** (a weak `/blog` can drag whole-site crawl priority) → keep a pruned index. Schema still earning results in 2026: FAQPage, HowTo, Product/Service/Offer, Organization, Review, Article — JSON-LD must match visible content exactly; **author-level Person schema** now matters for E-E-A-T + AI citation.

**What we do.**
- Single locale; correct `og:locale` + `<html lang>` (a free win — competitors ship en_US/en_GB on non-English sites, confirmed by the DE scan); never `hreflang`.
- The locked SEO `<head>` engine (`shared/seo-engine/`) emits title/meta/canonical/robots/OG/Twitter/favicon/font-preload + JSON-LD identically across the fleet; a layout variant physically cannot alter it.
- **5-schema baseline** on every site: WebSite + Organization + Product + FAQPage + BreadcrumbList (competitors typically ship ~2). HowTo on guides/device pages.
- Astro static output = SSR HTML by default (critical content in initial markup — satisfies the AI-crawler rule). WebP + lazy images; inlined critical CSS; Lighthouse ≥90; sitemap + robots; security headers; www→apex 301.
- Per-site **class salt + layout variants** break the template-network footprint (custom-class Jaccard ≈0 between sites).
- **Every page must be able to earn its own rankings — or it's dead weight.** Multi-page (one intent per page) is the proven winner's architecture in this market (DataForSEO ranked-pages, DE scan: smart-iptv-pro = 14 ranking pages, meiniptvanbieter = 20, both getting most non-homepage traffic from the app/device-guide cluster). **But page count is not a virtue.** The failure mode: iptvhafen.to has ~57 pages yet **only its homepage ranks** — the other ~56 pull ~zero organic traffic (dead crawl budget + thin-content risk). So: ship **intent-complete, not page-count-padded** — every page needs (a) a real target keyword no other page owns (no cannibalization) and (b) internal-link equity flowing into it. A page that can't rank shouldn't ship. The lever that *activates* a broad multi-page site is Off-Page (links) — see Pillar 4; until authority exists, concentrate internal-link equity on the core money pages + homepage.

**Enforced / detailed by:** `seo-audit-checklist.md §1`, `workflows/05_build_astro.md`, `workflows/08_deploy_cloudflare.md`, `tools/check-seo-lock.mjs`, `tools/footprint-report.mjs`, `page-architecture.md`.

**Open edge:** blog hero images are placeholders (`/images/blog/*.webp` 404) — generate before a true launch. INP isn't yet measured per-template in CI.

---

## 2. Content
*Topical authority and the content-cluster breadth that actually ranks.*

**2026 reality.** AI Overviews appear in ~50%+ of searches and have cut informational traffic 20–40%; surviving pages carry **unique data + first-hand testing**. **Experience** (the extra E in E-E-A-T) — real device screenshots, latency tests, "I used X for 3 months" — is the YMYL differentiator. Search is bimodal: it rewards **deep evergreen hubs** AND **high-velocity freshness** (price/lineup updates, "Last updated", change logs). Scaled programmatic AI content is poorly indexed in commercial YMYL — AI is a drafting assistant, not the publisher.

**What we do.**
- Keyword universe from the manual Semrush UI, **cross-validated against DataForSEO** (`tools/validate_keywords.py` — DE volume correlation r=0.83). Frozen Semrush stays source of truth; DfS corroborates.
- The money page covers the whole commercial cluster; the **app/device-guide cluster** (TiviMate, IPTV Smarters, Fire TV, M3U…) is the low-KD long-tail lever competitors win on — auto-planned into `blog_backlog` from the competitor content-cluster map.
- DMCA-safe framing always (`banned-phrases-dmca.md`) — never imply broadcaster licensing or "free premium channels". Native target language, no generic filler.
- Per guide: word-count ≥ competitor norm median (aim p75); 5–10 self-contained FAQs; a **"Rechtliche Hinweise"/testing-methodology E-E-A-T block**; a **named author with Person schema**; fresh `dateModified` + "Last updated" + year-in-title.

**Enforced / detailed by:** `workflows/01_keyword_research.md`, `03_intent_mapping.md`, `04_write_content.md`, `competitor-ranking-playbook.md`, `content-frontmatter-schema.md`, `agents/iptv-seo-writer.md`.

**Open edge:** no first-hand testing/screenshots or named-author bios on the sites yet — the biggest 2026 content gap. Add real experience signals per market.

---

## 3. On-Page SEO
*Per-page optimization to match-or-beat the ranking norm AND be extractable by AI.*

**2026 reality.** **Atomic answers** — a 40–60-word direct answer immediately under a question-style H2/H3 — are disproportionately lifted into AI Overviews and LLM answers. This is the single biggest on-page upgrade of 2026. Pros/cons blocks and comparison tables get quoted verbatim. **Entity SEO** (consistent brand naming + Organization/Person/sameAs) beats keyword density — semantic matching means stuffing the primary keyword no longer helps and can hurt.

**What we do.**
- Primary keyword in `<title>`; `<title>` ≈ `<h1>`; **exactly one `<h1>` per page** (we caught a duplicate-H1 bug across all blog posts — the layout renders the frontmatter H1, so the markdown body must NOT start with `# Title`).
- Meta title 50–60 chars / description 140–160. FAQ + FAQPage schema; HowTo on guides.
- **Question-style H2s with an atomic answer underneath**; comparison tables on money/listicle pages; pros/cons where natural.
- Internal links ≥ competitor-norm count, in topic-silo blocks with descriptive anchors; descriptive alt text in the target language.

**Enforced / detailed by:** `seo-audit-checklist.md §2`, `agents/iptv-seo-auditor.md` (competitive gate — warns if below the competitor schema/word/FAQ median for the page's target keyword, reading `ranking_factors.json`), `competitor-ranking-playbook.md`.

**Open edge:** the blog layout hardcodes `Article` JSON-LD, so guides declaring `HowTo` in frontmatter don't emit HowTo schema yet (rich-result eligibility lost) — spun off as a task. Atomic-answer formatting isn't yet enforced in the writer contract.

---

## 4. Off-Page SEO
*Authority, links, and brand signals — the likely #1 real ranking driver, not measured on-page.*

**2026 reality.** **Unlinked brand mentions + co-occurrence** now weigh heavily for both Google and LLM citation. Contextual niche-relevant links (tech / telecom / consumer-rights / cord-cutting media) far outweigh generic guest posts; data-driven digital PR earns them. **Brand search volume + review sentiment** (Trustpilot, Reddit, app stores) are ranking signals by proxy.

**What we do.**
- `/iptv-backlink-prospects {cc}` — finds domains linking to ≥2 competitors but not us, with drafted outreach. Our on-page scan proved competitors don't out-structure us; their edge is authority — so this pillar is where the ranking gap is actually won.
- Pursue data-driven PR angles specific to the niche (cost vs cable, latency benchmarks, legal-safety) and grow the review profile.

**Cost note.** DataForSEO **Backlinks API** moves to **commitment-free pay-as-you-go on 2026-07-01** (was $100/mo) — start backlink prospecting earlier per market; it just got cheaper to begin. (Memory: Semrush-first / DataForSEO gated — that stance holds; this is just the new economics.)

**Enforced / detailed by:** `commands/iptv-backlink-prospects.md`, `commands/iptv-rank-track.md`.

**Open edge:** DE backlink prospecting not yet run — the next high-leverage DE step. No brand-mention monitoring in place yet.

---

## 5. GEO — Generative Engine Optimization
*Get cited in ChatGPT / Perplexity / Google AI Overviews / Gemini. Complements, doesn't replace, classic SEO.*

**2026 reality.** ~40–45% of AI citations come from the **first 30% of a document** → front-load your best insight. Question + atomic-answer structure, FAQs, and comparison tables drive citations. **ChatGPT search uses Bing** as a key source — ranking in Bing improves ChatGPT citation. Distributing the same insight across multiple trusted sites (YouTube, Reddit, niche media) can ~3× AI citations. The emerging KPI is **Share of Synthesis**: how often your brand is cited in AI answers vs competitors, for a defined keyword set.

**What we do.**
- Enable AI crawlers (OpenAI, Perplexity, Anthropic, Google-Extended) in `robots.txt`; add an **`llms.txt`** declaring fair-game paths.
- Front-load insights; reuse the On-Page atomic-answer pattern (shared signal).
- Baseline + track LLM citations via `/iptv-geo-baseline {cc}` (`ai_opt_llm_ment_*` on DataForSEO) and rank tracking.

**Cost note.** DataForSEO **LLM Mentions API** also moves to **commitment-free pay-as-you-go on 2026-07-01** — GEO / Share-of-Synthesis tracking is now cheap to run per market.

**Enforced / detailed by:** `commands/iptv-geo-baseline.md`, `commands/iptv-rank-track.md`.

**Open edge:** no `llms.txt` shipped; AI-crawler robots policy not audited; Share-of-Synthesis not yet baselined for any market.

---

## Governing note

This is the framework all future IPTV builds follow. **After several sites are built and optimized against these pillars, fold the accumulated learnings back into the plugin** (workflows / agents / tools / a shared `llms.txt`). Do **not** pre-optimize the plugin before that — real-world reps validate what's worth automating.

---

## Sources (2026 SEO deep-research, via Perplexity)
- linksurge — 2026 SEO guide (INP/CWV thresholds, schema that still earns, JS/AI-crawler rendering)
- controlaltdigital — AI Search in 2026 / SEO + GEO complete guide (front-load 30%, llms.txt, Bing→ChatGPT, ~3× distribution, Share of Synthesis)
- eseospace — How AI Overviews impact SEO 2026 (~50% prevalence, 20–40% informational traffic loss, atomic answers)
- rankmax — Technical SEO (CWV, structured data, architecture)
- clickrank — SEO ranking factors (helpful-content-in-core, section demotion, link quality)
- solidappmaker — SEO in 2026 (E-E-A-T, search intent), darkroomagency — AI search tools 2026
