# Workflow: SEO Audit (iptv-seo-auditor) — 2026 Edition

**Type:** Pipeline step 07 (gate before deploy)
**Owner agent:** `iptv-seo-auditor` (see `agents/iptv-seo-auditor.md`)
**Reference checklist:** [`references/seo-audit-checklist.md`](../seo-audit-checklist.md)
**Governing framework:** [`references/seo-pillars.md`](../seo-pillars.md)

---

## Goal

Run a full 2026-aware SEO audit on `sites/{cc}/` against the upgraded `iptv-seo-auditor` agent and the `seo-audit-checklist.md`. The audit must enforce the 2026 ranking + AI-citation reality — not the pre-2026 generic playbook. **No deploy until 0 HARD FAILs.** WARNs are surfaced but do not block.

This workflow is the *driver*. It tells the orchestrator how to invoke the auditor, what to pass in, what gates to enforce, and how to route failures back. The *content* of every check lives in `seo-audit-checklist.md` — do not restate it here.

---

## Required Inputs

| Input | Path | Required? |
|---|---|---|
| Built site source | `sites/{cc}/` (every `.astro`, `.md`/`.mdx`, `astro.config.mjs`, `brand.yaml`, `public/robots.txt`, `public/llms.txt` if present) | yes |
| Built site dist (post `npm run build`) | `sites/{cc}/dist/` | yes — needed for SSR-HTML + image-404 checks |
| File manifest | full file list under `sites/{cc}/` (orchestrator generates) | yes |
| Frozen Semrush data (KW-coverage verification) | `seo-data-store/data/{cc}/normalised/keywords_top_*.json` + `paa_questions_*.json` | yes — for §2.4 secondary-KW body presence + §2.6 atomic-answer question sourcing |
| Competitor ranking norms (if §02 ran) | `.tmp/{country}_{lang}/ranking_factors.json` | optional — enables §2.9 word-count + §3.4 competitive gates |
| Banned phrases | `references/banned-phrases-dmca.md` | yes |
| SEO pillars | `references/seo-pillars.md` | yes (auditor reads first) |

If `dist/` is missing, run `npm run build` in `sites/{cc}/` before invoking the auditor — SSR-HTML completeness and image-404 checks cannot be evaluated otherwise.

---

## Procedure

### Step 1 — Pre-flight

1. Confirm `sites/{cc}/dist/` exists. If not, run `npm run build` from `sites/{cc}/` and verify zero build errors.
2. Generate the file manifest (every file the auditor must read): `astro.config.mjs`, `brand.yaml`, all `public/*`, all `src/pages/**/*.astro`, all `src/layouts/**/*.astro`, all `src/content/**/*.{md,mdx}`, the SEO engine head component, every schema component.
3. Check whether `.tmp/{country}_{lang}/ranking_factors.json` is present and pass its path if yes.

### Step 2 — Invoke the auditor

Spawn the `iptv-seo-auditor` agent with this context:

```
Agent: iptv-seo-auditor
Site: sites/{cc}/
Manifest: <full file list>
Frozen Semrush data: seo-data-store/data/{cc}/normalised/
Ranking factors (if present): .tmp/{country}_{lang}/ranking_factors.json
Banned phrases: references/banned-phrases-dmca.md
Reference checklist: references/seo-audit-checklist.md
Governing framework: references/seo-pillars.md

Task: Run the full 2026 audit (Sections 1–10 of your agent spec). Read every file in the manifest. Do not audit from memory. Return PASS / WARN / FAIL / HARD FAIL per check with file:line + exact fix + owner agent (iptv-tech-builder or iptv-seo-writer). Use the structured Output Format defined in your agent spec.
```

### Step 3 — Capture the report

The auditor returns a structured markdown report with these blocks (per its Output Format):

- `## Summary` — totals
- `## HARD FAILS (block deployment)` — each with `[Section X.Y]`, `file:line`, fix, owner, 2026 rationale
- `## FAILS (fix before deploy)` — same shape
- `## WARNINGS (recommended improvements)`
- `## Passed sections`
- `## Open-edge findings` — operator follow-up (e.g. backlink prospecting not yet run)
- `## Verdict` — `[APPROVED]` or `[NOT APPROVED]`

Persist the full report at `.tmp/{country}_{lang}/audit_report_<timestamp>.md`.

### Step 4 — Gate

- **Verdict `[APPROVED]` (0 HARD FAILs)** → proceed to Step 5 (Output Handoff). WARNs are flagged to the operator but do not block.
- **Verdict `[NOT APPROVED]`** → proceed to "Routing failures back" below. Do **not** advance to `08_deploy_cloudflare.md`.

---

## Gate Categories (high-level summary of the auditor's 10 sections)

The auditor's checklist lives in `references/seo-audit-checklist.md` and is enforced section-by-section by `agents/iptv-seo-auditor.md`. The 10 gate categories are:

1. **Technical SEO baseline** — `astro.config.mjs` site/adapter/sitemap, robots.txt, canonical, `<html lang>` + `og:locale` parity, OG/Twitter tags, SEO-lock engine adherence, footprint break (class salt + layout variant).
2. **On-Page SEO** (every indexable page) — title length + KW, meta-description length + KW, **exactly one H1 that is keyword-led (not brand-only)**, **declared secondary keywords must appear in body**, internal-link anchor quality (no "Mehr erfahren"/"Read more" weakness, money pages cross-link), **atomic answers** under question-style H2/H3, comparison tables on `vergleich` / `bestes-*` / pricing, breadcrumbs, word-count parity vs competitor norm.
3. **Schema markup (2026)** — 5-schema baseline (WebSite + Organization + Product + FAQPage + BreadcrumbList), HowTo on app/device guides, Article/BlogPosting on blogs, **schema-content alignment STRICT** (FAQPage Q/A must appear verbatim, no AggregateRating without visible ratings, no self-serving Review, HowTo requires real `<ol>`), no string-interpolated JSON (XSS), competitive-ranking gate vs `ranking_factors.json`.
4. **E-E-A-T & Entity** — **visible byline + Person schema** on every informational/YMYL-adjacent post, Organization consistency with `sameAs[]` (Trustpilot, Reddit, X), money-page disclaimer block in the first ~25%, About + Contact pages with operator name + real contact, first-hand testing language on app/device guides.
5. **Content quality** — no Lorem/TBD/TODO/Coming soon, **no banned DMCA-unsafe phrases**, no near-duplicate clusters (>80% shared body), no thin pages (<300 unique words), **no cannibalization** (two pages targeting the same KW), language purity (no English on a non-English site), correct currency + locale.
6. **Performance & CWV** — **SSR HTML completeness** (H1, intro, pricing, FAQ in initial HTML — AI crawlers don't execute JS), **zero raw `<img>`** (all images via Astro `<Image>`/`<Picture>` with `width`+`height`+`alt`), WebP/AVIF, hero `loading="eager" fetchpriority="high"`, **LCP < 2.5 s · CLS < 0.15 · INP < 200 ms** target, no referenced image 404 in `dist/`.
7. **GEO / AI-search** — **`robots.txt` must NOT block `GPTBot`, `Google-Extended`, `PerplexityBot`, `ClaudeBot`, `CCBot`, `Applebot-Extended`**, `public/llms.txt` presence (WARN if missing, HARD FAIL if it blanket-denies LLMs), **front-loading** (no money page opens with >300 words of brand storytelling before the value prop), Bing-friendly hygiene (no `bingbot` block), jump links / TOC on long-form (>1200 words).
8. **Off-Page hooks visible in repo** — Organization `sameAs[]` present, `/about/` exists with named operator, contact mechanism present, open-edge: `/iptv-backlink-prospects {cc}` not yet run.
9. **Forms & API** — contact form fields + honeypot (`tabindex="-1"`) + client-side validation + loading state + inline success/error, `pages/api/contact.ts` has `export const prerender = false` + server-side validation, recipient email from `brand.yaml` (not hardcoded).
10. **Design quality** (footprint break) — brand-colored shadows (not default gray), per-site class salt applied, layout variant differs from the most recent live site, gradient mesh + grain overlay present, bento layout in at least one card grid, gradient text on at least one heading, hover changes ≥ 2 properties.

---

## 2026 Critical Gates (call these out explicitly)

The five gates below carry the most ranking + AI-citation weight in 2026. They are HARD FAILs in the auditor for a reason — every one of them encodes a real fleet finding or a top-3 finding from the 2026 SEO research foundation.

1. **Atomic answers** under every question-style H2/H3 (40–80 words, paragraph-first not bullets-only). *The single biggest 2026 on-page win* — pros/cons and comparison tables get lifted verbatim into AI Overviews. ([Semrush Google AI Mode](https://www.semrush.com/blog/google-ai-mode/), [snoika 2026 SEO best practices](https://snoika.com/blog/seo-best-practices-2026))
2. **`robots.txt` AI-crawler allow + `llms.txt` present** — the AI-citation lever. Blocking `GPTBot` / `Google-Extended` / `PerplexityBot` / `ClaudeBot` / `CCBot` kills GEO upside. ChatGPT search uses Bing — never block `bingbot`. ([controlaltdigital AI search 2026](https://controlaltdigital.com/ai-search-seo-geo-2026-guide))
3. **Schema-content alignment (STRICT)** — FAQPage Q/A text must appear in the visible HTML; no AggregateRating without visible ratings; no self-serving Review. Google's 2026 validation rejects mismatches and harms trust. ([digitalapplied schema 2026](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026))
4. **Declared secondary keywords must appear in the body** — the DE-homepage anti-pattern we hand-caught: "iptv anbieter" (9.9k/mo), "iptv abonnement", "iptv test" declared as secondary KWs with 0 body occurrences. Each declared KW must appear ≥ 1× (WARN if < 2× on money pages, WARN if > 4% density).
5. **H1 is keyword-led, not brand-only** — also from the DE homepage fix. Brand-only H1s on money pages leak ranking value because the H1 is the strongest on-page signal. Plus the corollary: **exactly one H1 per page** (blog layouts must not double-render the frontmatter H1 + a markdown `# Title`).

Adjacent but equally hard:

- **SSR HTML completeness** — H1, intro, pricing, FAQ, atomic answer must be in the initial HTML. AI crawlers + Bing often don't execute JS, so client-rendered critical content is invisible to them.
- **Jan 2026 Google core update correlated with >40% drops in ChatGPT citations** for sites that lost Google rank — organic health is now the primary input to AI visibility. ([mean.ceo / 2026 AI-search dependence](https://blog.mean.ceo/startup-news-ai-search-dependence-google-rankings-2026/))
- **Front-loading** — ~40–45% of AI citations come from the first 30% of a document. ([digitalapplied zero-click 2026](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026))

---

## Routing failures back

The auditor's structured report already maps each non-PASS to its owner agent (`iptv-tech-builder` or `iptv-seo-writer`) with `file:line` + the exact fix. The workflow just acknowledges and dispatches:

- **For each HARD FAIL** → spawn the named owner agent with the specific finding (file, line, fix). Examples:

  > **`iptv-seo-writer`**: `src/pages/iptv-anbieter.astro:42` — H1 is "IPTV Anbieter – Jetzt entdecken" (brand-only). Replace with a keyword-led H1, e.g. "Seriöser IPTV Anbieter in Deutschland — Live-TV, Sport und Filme". (Section 2.3 — brand-only H1 anti-pattern.)

  > **`iptv-tech-builder`**: `src/layouts/BlogLayout.astro:18` — JSON-LD hardcodes `"@type": "Article"`. Post `tivimate-fire-tv-anleitung.md` declares `schema: HowTo` in frontmatter. Read frontmatter `schema` field, emit `HowTo` with `step[]` from the post's `<ol>` items. (Section 3.1 open-edge.)

  > **`iptv-tech-builder`**: `public/robots.txt:5` — `Disallow: /` under `User-agent: *` blocks AI crawlers. Replace with explicit allow blocks for `GPTBot`, `Google-Extended`, `PerplexityBot`, `ClaudeBot`, `CCBot`, `Applebot-Extended`. (Section 7.1 — GEO.)

- **For each FAIL** → same routing, but the agent has discretion to batch.
- **For each WARN** → log to the operator at the end of the audit report; do not block.

After fixes ship, re-invoke the auditor **only on the previously-failing items** (the agent supports targeted re-audit per its protocol). Do not re-audit the whole site unless the orchestrator changed > 5 files.

---

## Tool Reference

Tools live in `/Users/boullamjaouad/Code/iptv-fleet/tools/` (the fleet repo, not the plugin):

| Tool | Purpose | Run from |
|---|---|---|
| `tools/check-seo-lock.mjs` | Verify no page hard-codes a `<title>` or meta outside the locked `seo-engine/`. Backs Section 1.5. | fleet repo, against `sites/{cc}/` |
| `tools/footprint-report.mjs` | Compute Jaccard class overlap vs other fleet sites. Should be ≈ 0. Backs Section 1.6 + 10.5. | fleet repo, against `sites/{cc}/` |
| `tools/salt-classes.mjs` | Apply per-site Tailwind class salt (used by `iptv-tech-builder`, not the auditor — listed for context). | fleet repo |
| `tools/schema_validate.py` | Local schema.org JSON-LD validation. Sanity-check before relying on rich-results.google.com. | fleet repo |
| `tools/a11y_check.py` | axe-core via Playwright. Optional supplementary a11y pass. | fleet repo |
| `tools/pagespeed.py` | PSI API → CWV numbers (LCP / CLS / INP). Use post-deploy to verify Section 6.4 targets. | fleet repo |
| `tools/link_check.py` | Internal-link integrity + `dist/` image-404 detection. Backs Section 2.5 + 6.2. | fleet repo, against `sites/{cc}/dist/` |

External tools the auditor relies on:

- **rich-results.google.com** — Google's Rich Results Test. Spot-check any non-trivial schema change.
- **PageSpeed Insights** (psi.google.com) — post-deploy CWV verification (LCP < 2.5 s · CLS < 0.15 · INP < 200 ms).

---

## Output Handoff

- **PASS (0 HARD FAILs)** → save the report at `.tmp/{country}_{lang}/audit_report_<timestamp>.md` and hand off to [`08_deploy_cloudflare.md`](./08_deploy_cloudflare.md). Surface the WARN list + open-edge findings to the operator with the handoff message.
- **FAIL (≥ 1 HARD FAIL)** → save the report, dispatch fixer agents per the auditor's owner routing, wait for fixes to land, then re-run the auditor on only the failing items. Loop until APPROVED. Never mark "launch ready" with open HARD FAILs.
- **Operator open-edges** (e.g. "backlink prospecting via `/iptv-backlink-prospects {cc}` not yet run", "Bing Webmaster Tools sitemap not submitted", "llms.txt missing") → record in the deploy handoff; do not block.
