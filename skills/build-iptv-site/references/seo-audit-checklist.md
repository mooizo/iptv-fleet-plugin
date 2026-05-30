# SEO Audit Checklist — 2026 IPTV Edition

This is the gate the `iptv-seo-auditor` agent enforces against `sites/{cc}/` before deploy. The agent owns the prose, routing, and reporting; **this file owns the binary pass/fail gate**. Mirror the agent's 10 sections 1:1. If any **HARD FAIL** trips, deployment is blocked — the agent routes the fix to `iptv-tech-builder` or `iptv-seo-writer` and the audit re-runs.

Use `- [ ]` items as runnable checks against built HTML (`dist/`), source files (`src/`, `public/`, `astro.config.mjs`, `brand.yaml`), or emitted JSON-LD. Every check should be mechanically verifiable.

---

## 2026 Research Foundation

Each HARD FAIL below is grounded in the 9 cited findings in [`agents/iptv-seo-auditor.md`](../../../agents/iptv-seo-auditor.md) → "2026 Research Foundation" block. Do not restate them here — when a check fires, quote the relevant finding from the auditor agent to the operator. Key inputs driving this checklist:

- Jan 2026 Google core update → AI citations track Google rankings (>40% citation drop on ranking loss).
- AI Overviews on ~50–60% of queries; **58.5% zero-click**; up to 83% AI-answered queries end without a visit.
- **Atomic answers + comparison tables** are the disproportionate 2026 on-page win.
- ~40–45% of AI citations come from the **first 30%** of a document → front-load.
- **INP < 200ms / LCP < 2.5s / CLS < 0.15** is the 2026 CWV bar.
- AI crawlers often **don't execute JS** → SSR HTML must contain critical content.
- "Recognition, not rankings" → entity clarity drives both Google + LLM citation.
- Schema-content alignment is now **enforced** — invisible FAQ/HowTo schema is flagged.
- ChatGPT search uses **Bing** as a primary source.
- Distributing the same insight across multiple trusted sites can ~3× AI citation rate (Share of Synthesis).

---

## Section 1 — Technical SEO baseline

### 1.1 Build config
- [ ] `astro.config.mjs` `site` is the production domain (not localhost, not a placeholder)
- [ ] `astro.config.mjs` includes Cloudflare adapter + `@astrojs/sitemap` + `astro-robots-txt`
- [ ] Output mode is correct for the deploy target; no accidental `prerender = false` outside API routes
- [ ] `compressHTML: true` and `build.inlineStylesheets: 'auto'` set

### 1.2 Sitemap & robots
- [ ] `/sitemap-index.xml` will exist post-build and lists every indexable page
- [ ] `public/robots.txt` references `/sitemap-index.xml` and does not block `bingbot`
- [ ] **HARD FAIL** if `robots.txt` blocks any AI crawler — `GPTBot`, `Google-Extended`, `PerplexityBot`, `ClaudeBot`, `CCBot`, `Applebot-Extended`. Kills GEO citation potential. ([controlaltdigital AI search 2026](https://controlaltdigital.com/ai-search-seo-geo-2026-guide))

### 1.3 Canonical & language
- [ ] BaseHead emits `<link rel="canonical">`; every page passes a `canonical` prop matching the final production URL (no staging hostnames)
- [ ] **HARD FAIL** if `<html lang>` does not match the site's target country language (DE → `de`, NL → `nl`, FR → `fr`, etc.). Free win competitors regularly miss.
- [ ] **HARD FAIL** if `og:locale` is `en_US` or `en_GB` on a non-English site. Must be `de_DE`, `nl_NL`, `fr_FR`, etc.
- [ ] No `hreflang` tags (single-locale rule)

### 1.4 Open Graph / Twitter
- [ ] BaseHead emits `og:title`, `og:description`, `og:image`, `og:type`, `og:url`, `og:locale` on every page
- [ ] Twitter `summary_large_image` card tags present
- [ ] OG image references an existing file in `public/`, dimensions ≥ 1200×630, < 5 MB

### 1.5 SEO-lock engine
- [ ] Every page routes its `<head>` through the shared `seo-engine/`
- [ ] No page hard-codes a `<title>` or meta tag outside the engine
- [ ] `tools/check-seo-lock.mjs` passes (zero engine deviation)

### 1.6 Footprint break (Pillar 1)
- [ ] Per-site Tailwind class salt applied
- [ ] `tools/footprint-report.mjs` shows Jaccard ≈ 0 vs other live fleet sites
- [ ] Layout variant differs from the most recent live site

### 1.7 Deploy readiness
- [ ] `npm run build` succeeds with zero warnings; `dist/` under 10 MB
- [ ] No `console.log` / debug output in shipped JS
- [ ] Favicons (SVG, 32px PNG, 180px apple-touch-icon) and `theme-color` matching brand primary hex
- [ ] `_headers` ships CSP, HSTS, X-Content-Type-Options, X-Frame-Options, Permissions-Policy; `_redirects` does www→apex 301

---

## Section 2 — On-Page SEO (every indexable page)

Page roles inferred from filename + content: **money** (`index.astro`, `iptv-abo`, `iptv-anbieter`, `iptv-kaufen`, `bestes-iptv-*`, `iptv-vergleich`, `pricing`), **trust** (`about`, `contact`, `iptv-legal-*`), **conversion** (`free-trial`), **app/device guides** (blog `.md`/`.mdx`), **hub** (`blog/index`, `faq`).

### 2.1 Title tags
- [ ] **HARD FAIL** if `<title>` is < 50 or > 60 characters (report exact count)
- [ ] **HARD FAIL** if `<title>` does not contain the page's declared primary keyword
- [ ] Title semantically matches the H1 (AI extraction alignment)

### 2.2 Meta descriptions
- [ ] **HARD FAIL** if `meta description` is < 140 or > 160 characters
- [ ] Primary keyword appears near the start of the description
- [ ] Ends with a target-language action verb / CTA (no "Learn more", "Click here")

### 2.3 H1 — exactly one, primary-keyword-led, NOT brand-only
- [ ] **HARD FAIL** if the rendered page has **zero or > 1** `<h1>` (blog trap: layout renders frontmatter H1 *and* body opens with `# Title` → duplicate)
- [ ] **HARD FAIL** if the H1 is **brand-only** on any money page (e.g., "IPTV Klar: Live-TV") and does not contain the primary keyword unbroken. *DE-homepage anti-pattern.* Brand-only H1s leak ranking value.
- [ ] H1 contains the primary keyword within its first 8 words, unbroken
- [ ] No heading-level skips (H1 → H2 → H3, never H1 → H3)

### 2.4 Declared secondary keywords MUST appear in body
*Encodes the DE-homepage finding where "iptv anbieter" (9.9k/mo), "iptv abonnement", "iptv test" were declared secondary KWs with **zero body occurrences**.*
- [ ] **HARD FAIL** for any page where the declared **primary** keyword has 0 body occurrences
- [ ] **HARD FAIL** for any page where any declared **secondary** keyword has 0 body occurrences
- [ ] **WARN** if a declared secondary keyword appears < 2 times on a money page
- [ ] **WARN** if any keyword exceeds 4% body density (semantic matching → stuffing hurts)

### 2.5 Internal-link anchor quality
*Encodes the DE-homepage finding where link cards used weak/brand-only anchors and PageRank flowed without signal.*
- [ ] **HARD FAIL** if > 30% of internal `<a>` tags on a single page use generic anchors (`Learn more`, `Read more`, `Mehr erfahren`, `Hier klicken`, brand-only)
- [ ] **HARD FAIL** if the homepage does not link to **every** money page in its `relatedPages` / link-card section (DE caught at `0a52d17`)
- [ ] Each money page links to ≥ 2 sibling money pages with keyword anchors
- [ ] Each app/device guide links back to its money page with a keyword anchor
- [ ] **WARN** if internal-link count is below `ranking_factors.norm.internal_links_median` (if present in `.tmp/{country}_{lang}/ranking_factors.json`)

### 2.6 Atomic answers (the biggest 2026 on-page win)
- [ ] **HARD FAIL** on money pages + app/device guides if no question-style H2/H3 (text ending with `?`) exists. ([Semrush AI Mode](https://www.semrush.com/blog/google-ai-mode/))
- [ ] For each question-style heading, the **immediately-following block** is a 40–80-word self-contained, declarative answer paragraph
- [ ] **WARN** if the answer is < 30 or > 100 words, or is a bullet list with no leading paragraph
- [ ] Question headings map to real conversational queries in `seo-data-store/data/{cc}/paa_questions_*.json` when available

### 2.7 Comparison tables & pros/cons
- [ ] **HARD FAIL** on `iptv-vergleich.astro` / `bestes-iptv-deutschland.astro` / any "vs" / "best of" page if no `<table>` element exists. AI Overviews lift these verbatim. ([snoika 2026 SEO best practices](https://snoika.com/blog/seo-best-practices-2026))
- [ ] Comparison tables have semantic `<thead>` + descriptive `<th>` (no generic "Option 1")
- [ ] Pricing page contains a tier comparison table or structured pricing list

### 2.8 Breadcrumbs
- [ ] Every non-homepage page renders a visible breadcrumb trail
- [ ] `BreadcrumbList` JSON-LD emitted with `position` integers from 1 and **absolute** URLs (see §3)

### 2.9 Word-count parity
- [ ] **WARN** if rendered body text is below `ranking_factors.norm.word_count_median` for the page role
- [ ] Money pages aim for ≥ p75 of competitor norm
- [ ] App/device guides ≥ 800 rendered body words

---

## Section 3 — Schema markup (2026 strict)

### 3.1 5-schema baseline + HowTo on guides
- [ ] `WebSite` on homepage only
- [ ] `Organization` on every page (sitewide via BaseHead)
- [ ] `Product` on money/pricing page with `name`, `description`, `offers.priceCurrency`, `offers.price`, `offers.availability`
- [ ] `FAQPage` on every page that renders a visible FAQ section
- [ ] `BreadcrumbList` on every non-home page
- [ ] `Article` / `BlogPosting` on blog posts, with `author` referencing a `Person` node (see §4)
- [ ] **HARD FAIL** if a blog post declares `schema: HowTo` in frontmatter but the layout emits only `Article` (known open-edge — flag explicitly until fixed)

### 3.2 Schema-content alignment (enforced in 2026)
- [ ] **HARD FAIL** if any `FAQPage` Q/A pair's text does not appear verbatim in the page's visible HTML. ([digitalapplied schema 2026](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026))
- [ ] **HARD FAIL** if `AggregateRating` is emitted on a page that shows no visible ratings
- [ ] **HARD FAIL** on self-referential `Review` schema (Organization reviewing itself)
- [ ] **HARD FAIL** if `HowTo` schema is emitted but the page contains no `<ol>` of steps with `name` + `text`
- [ ] `Product.offers.price` matches the visible price on the page (cross-check against `pricing.astro` / `brand.yaml`)

### 3.3 Schema safety (XSS)
- [ ] **HARD FAIL** if any schema component uses string-interpolated JSON (`${variable}` inside JSON strings) instead of `set:html={JSON.stringify(schema)}`
- [ ] All schema values passed as typed variables, never constructed via string concatenation

### 3.4 Competitive ranking gate (reads `.tmp/{country}_{lang}/ranking_factors.json` if present)
- [ ] **WARN** if page JSON-LD `@type` count is below `norm.schema_types_max_seen` (ship MORE schema than competitors, not less)
- [ ] **WARN** if a page with a FAQ has fewer Q&As than `norm.faq_count_median`
- [ ] **WARN** if a "MISSING" guide cluster from `ranking_playbook.md` has no corresponding published page

---

## Section 4 — E-E-A-T & Entity SEO

### 4.1 Author attribution (the 2026 differentiator)
- [ ] **HARD FAIL** on any blog post / app guide / device guide missing a visible byline ("Von [Name]" / "By [Name]")
- [ ] **HARD FAIL** on any informational / YMYL-adjacent post missing **Person schema** linked via the article's `author` property. Person node must have at minimum `name` + (`url` OR `sameAs[]`). ([Search Engine Land — recognition not rankings](https://searchengineland.com/seo-goal-recognition-476756))
- [ ] Author bio block on every blog post with credentials + link to `/about/` or `/authors/{slug}/`

### 4.2 Organization entity consistency
- [ ] Exactly one primary `Organization` node per page (no conflicting copies)
- [ ] Organization `name` is identical across all pages
- [ ] **WARN** if Organization is missing `sameAs[]` (Trustpilot, Reddit, X) — unlinked brand mentions are a major 2026 signal
- [ ] `logo` URL resolves; square or wide SVG/PNG ≥ 112×112

### 4.3 Trust signals on money / legal pages
- [ ] **HARD FAIL** if money pages are missing a visible disclaimer / Rechtliche-Hinweise block in the first ~25% of content (YMYL-adjacent niche)
- [ ] Money page links to the `iptv-legal-*` page with a keyword anchor
- [ ] About page exists with operator name, credentials, contact details
- [ ] Contact page has a working email + (if applicable) phone + legal address

### 4.4 First-hand experience signals (the "E" most IPTV sites lack)
- [ ] **WARN** if app/device guides contain no real screenshots, real device names + versions, or first-hand testing language
- [ ] **WARN** if a blog post has no `dateModified` newer than `datePublished` and no visible "Zuletzt aktualisiert" / "Last updated" line

---

## Section 5 — Content quality

### 5.1 Anti-patterns (HARD FAIL)
- [ ] **HARD FAIL** on visible "Lorem ipsum", "TBD", "TODO", "PLACEHOLDER", "Coming soon"
- [ ] **HARD FAIL** on DMCA-unsafe phrases — cross-check `references/banned-phrases-dmca.md`. Banned examples include: "official Netflix", "licensed by [broadcaster]", "free premium channels", any phrasing implying broadcaster licensing
- [ ] **HARD FAIL** on near-duplicate clusters: any two pages with > 80% shared body text
- [ ] **HARD FAIL** on thin pages: < 300 words of unique body text where template boilerplate is > 60% of total. Drags site-level crawl priority (helpful-content-in-core demotion). ([eseospace AI Overviews 2026](https://eseospace.com/blog/how-ai-overviews-impact-seo-2026/))
- [ ] **HARD FAIL** on keyword cannibalization: any two pages targeting the same primary keyword (DE fix at `d36e5e2`)
- [ ] Every numeric claim resolves to an entry in `verified_claims.json`

### 5.2 Language purity & currency
- [ ] **HARD FAIL** on any English sentence in body text of a non-English site (e.g., "Get started now" in a German hero)
- [ ] **HARD FAIL** on any wrong-currency reference (verify against `brand.yaml` currency — € on .de/.nl, £ on UK, etc.)
- [ ] **HARD FAIL** on wrong-country place names (no "United States" on a German site)
- [ ] Language detection ≥ 99% confidence on every page (`lingua-language-detector`)

### 5.3 CTAs
- [ ] Every money page has ≥ 3 CTA placements (hero, mid-page, bottom)
- [ ] CTA labels are action-specific in the target language
- [ ] At least one CTA references the free trial where it exists

---

## Section 6 — Performance & Core Web Vitals

### 6.1 SSR HTML completeness (AI-crawler readability)
- [ ] **HARD FAIL** if H1, intro paragraph, pricing table, FAQ, or atomic answer is rendered client-side via JS (visible only after hydration). AI crawlers + Bing often don't execute JS.
- [ ] Astro static output: all critical content present in initial HTML response

### 6.2 Image rules
- [ ] **HARD FAIL** if any `.astro` file uses a raw `<img>` tag for a non-decorative image (must use Astro `<Image>` / `<Picture>`)
- [ ] Every `<Image>` has `width` + `height` set (CLS prevention)
- [ ] Every `<Image>` has descriptive `alt` text in the target language (5–15 words, no "image of" / "photo of")
- [ ] Hero images: `loading="eager"` + `fetchpriority="high"`; non-hero: `loading="lazy"`
- [ ] WebP / AVIF output; fonts preloaded
- [ ] **HARD FAIL** if any referenced image returns 404 in `dist/` (known open-edge: `/images/blog/*.webp` placeholders)

### 6.3 Above-the-fold weight
- [ ] **WARN** if total head `<script>` byte weight > 150 KB uncompressed
- [ ] **WARN** on auto-play hero video without lazy-loading
- [ ] `prefers-reduced-motion` respected in any GSAP / animation init
- [ ] No render-blocking JS (use `is:inline` or `defer`)

### 6.4 CWV targets (verifiable post-deploy)
- [ ] **LCP < 2.5s** on every template
- [ ] **CLS < 0.15** on every template
- [ ] **INP < 200ms** on every template *(2026 metric — replaces TBT/FID)*
- [ ] Lighthouse Performance ≥ 90 mobile / ≥ 95 desktop; SEO = 100; Accessibility ≥ 90; Best Practices ≥ 90

---

## Section 7 — GEO / AI-search optimization

### 7.1 AI crawler access (robots.txt)
- [ ] **HARD FAIL** if `robots.txt` blocks any of: `GPTBot`, `Google-Extended`, `PerplexityBot`, `ClaudeBot`, `CCBot`, `Applebot-Extended` *(restated from §1.2 — this is THE GEO blocker)*
- [ ] **WARN** if `robots.txt` does not explicitly enumerate the above AI crawlers (default-allow is fine but explicit is safer)

### 7.2 llms.txt
- [ ] **WARN** if `public/llms.txt` does not exist (open-edge until fleet baseline ships one)
- [ ] **HARD FAIL** if `public/llms.txt` exists and blanket-denies all LLMs (would kill the citation play)
- [ ] If present, `llms.txt` lists: site name, one-line description, contact, and key URLs (pricing, FAQ, app guides) LLMs should prefer for citation

### 7.3 Front-loading (~40–45% of AI citations come from the first 30%)
- [ ] **HARD FAIL** on any money page that opens with > 300 words of brand storytelling before the primary value proposition / first atomic answer. ([digitalapplied zero-click 2026](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026))
- [ ] First viewport contains: primary keyword in H1, atomic answer or value prop, and a CTA

### 7.4 Bing-friendly hygiene (ChatGPT search uses Bing)
- [ ] No bot-blocking on `bingbot` in `robots.txt`
- [ ] Record operator TODO: sitemap submitted to Bing Webmaster Tools (not file-checkable)

### 7.5 Jump links / modular Q&A
- [ ] **WARN** on long-form pages (> 1200 words) with < 3 question-form headings or no in-page anchor / table of contents

---

## Section 8 — Off-Page hooks (visible from the repo)

Backlinks are not file-checkable, but on-site hooks that *make* off-page work easier are.

- [ ] **WARN** if Organization schema is missing `sameAs[]` (Trustpilot, Reddit, X) — co-occurrence + brand-mention signal
- [ ] **WARN** if no `/about/` page exists, or it has no operator name (brand entity clarity)
- [ ] **WARN** if no email / contact mechanism exists for outreach replies
- [ ] Record open-edge: "`/iptv-backlink-prospects {cc}` not yet run" → operator action, not auto-fixable

---

## Section 9 — Forms & API

IPTV sites carry contact forms but lead-gen is not the funnel — keep this brief.

### 9.1 Contact form (if present)
- [ ] Name, email, phone (optional), message fields present
- [ ] Honeypot hidden field with `tabindex="-1"`
- [ ] Client-side validation for required fields; submit button shows loading state
- [ ] Success + error states handled inline (no full page reload)

### 9.2 API route
- [ ] `pages/api/contact.ts` has `export const prerender = false`
- [ ] Server-side required-field validation + honeypot check + email format check
- [ ] Recipient email loaded from `brand.yaml` / `siteConfig` (not hardcoded placeholder)

---

## Section 10 — Design quality (footprint break)

Non-template, non-AI-look bar — otherwise the footprint scanner clusters us with other AI-built sites.

### 10.1 Visual depth
- [ ] Brand-colored shadows (not default gray `shadow-md` / `shadow-lg`)
- [ ] ≥ 2 sections use a gradient mesh / decorative background element
- [ ] Hero uses a multi-stop gradient overlay (not a flat tint)
- [ ] Optional grain / noise overlay component included in BaseLayout

### 10.2 Layout sophistication
- [ ] ≥ 1 card grid uses a bento layout (one card spans `col-span-2` or `row-span-2`)
- [ ] Homepage alternates ≥ 2 distinct section background colors
- [ ] Long text blocks use `max-w-prose` or equivalent

### 10.3 Typography
- [ ] Hero heading uses ≥ `text-5xl` mobile, ≥ `text-7xl` desktop
- [ ] ≥ 1 heading per template uses gradient text (`bg-clip-text text-transparent bg-gradient-to-r`)
- [ ] Display font on at least one heading level

### 10.4 Interactions
- [ ] Primary buttons change ≥ 2 properties on hover (e.g., `-translate-y` + `shadow`)
- [ ] Cards use `hover:-translate-y-1`, not `hover:scale`
- [ ] FAQ component uses an animated icon (plus → minus), not a character swap
- [ ] Form inputs have branded focus states (colored border or glow, not browser default)

### 10.5 Footprint break (Pillar 1 verification)
- [ ] Per-site class salt applied (class names differ from other live fleet sites)
- [ ] Layout variant differs from the most recent live site

---

## Verdict gate

After running every check above, compute the gate:

- [ ] **If any HARD FAIL trips → BLOCK DEPLOY.** The `iptv-seo-auditor` agent routes each failure to its owner (`iptv-tech-builder` or `iptv-seo-writer`), fixes are applied, and this checklist re-runs against the updated build. Only previously failing items are re-checked.
- [ ] **If only FAILs trip → fix before deploy** (non-blocking technically, but the auditor will not stamp APPROVED).
- [ ] **If only WARNs trip → ship is allowed**, but every WARN is logged in the operator report.
- [ ] **If zero HARD FAILs and zero FAILs → APPROVED for `/iptv-deploy {cc}`.**

The auditor agent owns routing-back-to-fixer logic and the final report format. This checklist owns the gate.
