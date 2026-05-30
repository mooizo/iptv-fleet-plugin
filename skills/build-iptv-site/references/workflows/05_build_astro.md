# Workflow: Build Astro Project (iptv-tech-builder)

**Goal:** Scaffold the entire `sites/{cc}/` Astro project for an IPTV fleet site — extend `@iptv-fleet/astro-base`, wire `brand.yaml` → `seo.config.ts` → the locked `@iptv-fleet/seo-engine`, generate per-country pages from the page_map, and ship the 2026 GEO scaffolding (`robots.txt` permissive to AI crawlers + `public/llms.txt`). Single-language, single-country — no `hreflang`, no `/en/` prefixes. Output must (a) pass `iptv-seo-auditor` on first audit and (b) carry a per-site footprint break so no two fleet sites cluster.

This workflow is the **driver**. The component-level executor is [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md) — point to it for per-page composition detail, per-component contracts, design system, and animation patterns. Don't restate; cite.

---

## Required Inputs

| Input | Source | Notes |
|---|---|---|
| `brand.yaml` | operator (Phase 1 of /iptv-new) | brand, domain, palette, fonts, layout variant, class_salt |
| `page_map.json` | `03_intent_mapping.md` | URL → primary_keyword → page_type → schema_types |
| `src/content/pages/*.md` + `src/content/blog/*.md` | `04_write_content.md` via `iptv-seo-writer` | frontmatter already conforms to the Zod schemas below |
| `.tmp/{country}_{lang}/ranking_factors.json` (optional) | `02_competitor_analysis.md` | structural bar to match-or-beat; fleet defaults if absent |
| `fleet.config.yaml` | repo root | `class_salt` per CC, domains, sitemap of fleet |

If `ranking_factors.json` is absent (rapid test build), fall back to fleet defaults: 4-schema baseline + HowTo on guides, 1,200-word floor on money pages, 5 FAQs, correct locale.

---

## Step 1 — Scaffold from `@iptv-fleet/astro-base`

`sites/{cc}/` is a pnpm workspace member, NOT a standalone `npm create astro@latest` project. Create `sites/{cc}/` and author `package.json` declaring workspace deps (`@iptv-fleet/astro-base`, `@iptv-fleet/seo-engine`, `@iptv-fleet/tokens` — all `workspace:*`) + `astro ^4.16`, `@astrojs/sitemap 3.2.1`, `@astrojs/tailwind ^5.1`, `tailwindcss ^3.4`, `sharp ^0.33`. Scripts: `dev` / `build` / `preview` / `deploy: wrangler pages deploy dist --project-name={cloudflare_project}`. Canonical version in [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md#packagejson).

From repo root: `pnpm install`. Verify workspace symlinks — `node_modules/@iptv-fleet/seo-engine` must point into `shared/seo-engine/`, not a downloaded package.

---

## Step 2 — Astro config (`astro.config.mjs`)

```javascript
export default defineConfig({
  site: 'https://{SITE_DOMAIN}',          // from brand.yaml
  integrations: [
    tailwind({ applyBaseStyles: false }),
    sitemap({ serialize: /* freq weekly:home+pricing, monthly:rest; priority 1.0/0.9/0.7/0.6 */ }),
  ],
  build: { inlineStylesheets: 'always' },
  compressHTML: true,
});
```

Full serialize() (priority tiers per URL pattern) in [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md#astroconfigmjs).

**Note (2026 reality):** the fleet ships **static Astro** — Cloudflare Pages serves `dist/`. **Do NOT add `@astrojs/cloudflare`** unless the site needs server endpoints (e.g. `pages/api/contact.ts`). Static output keeps H1, plans, FAQ in initial SSR HTML — required because AI crawlers and Bing often don't execute JS ([controlaltdigital AI search 2026](https://controlaltdigital.com/ai-search-seo-geo-2026-guide)).

---

## Step 3 — Directory structure

```
sites/{cc}/
├── astro.config.mjs · brand.yaml · package.json · tailwind.config.mjs · tsconfig.json
├── public/
│   ├── robots.txt              # AI crawlers explicitly allowed (Step 8)
│   ├── llms.txt                # llmstxt.org spec (Step 8 — F-5 fix)
│   ├── _headers / _redirects   # Cloudflare Pages
│   ├── favicon.svg · apple-touch-icon.png · favicon-32.png
│   ├── fonts/                   # woff2 matching seoConfig.fontPreloads
│   └── images/                  # og-default.webp, logo.svg, hero assets
└── src/
    ├── seo.config.ts           # brand.yaml → typed SeoConfig
    ├── content/{config.ts, pages/*.md, blog/*.md}    # Zod (Step 4 — HF-7)
    ├── components/             # per-site or imported from astro-base
    ├── layouts/BaseLayout.astro # wraps SeoHead + Header + Footer
    ├── lib/schema.ts           # re-exports createSchemaBuilders(seoConfig)
    ├── data/pricing.ts         # single source of truth for plans + productOffers
    └── pages/
        ├── index.astro · pricing.astro · free-trial.astro
        ├── iptv-{country}.astro · iptv-anbieter.astro · iptv-abo.astro
        ├── iptv-kaufen.astro · iptv-vergleich.astro · bestes-iptv-{cc}.astro
        ├── iptv-legal-{cc}.astro · installation.astro
        ├── about.astro · contact.astro · faq.astro · 404.astro
        └── blog/{index.astro, [...slug].astro}   # iterates schema_types
```

Per-country page filenames come from the page_map (German shown; French/Dutch/Italian variants per writer's slug rules). Locked URL roles + section orders: [`references/page-architecture.md`](../page-architecture.md). Per-page component composition: [`references/component-library.md`](../component-library.md). Frontmatter contract: [`references/content-frontmatter-schema.md`](../content-frontmatter-schema.md).

---

## Step 4 — Content collection schemas (the HF-7 fix)

`src/content/config.ts` enforces SEO length constraints AT THE SOURCE so `astro build` errors before the auditor sees an out-of-range string. **DE shipped without these constraints — the auditor caught 60+ char titles and 200+ char descriptions. Do not regress.** The strict constraints (HARD):

```ts
// Excerpts — full Zod in agents/iptv-tech-builder.md "Content collection schemas".
const pages = defineCollection({
  type: 'content',
  schema: z.object({
    page_type: z.enum(['homepage','pricing','trial','channels','devices_index',
                        'device','installation','faq','about','contact','legal',
                        'money','comparison','blog']),
    primary_keyword: z.string(),
    secondary_keywords: z.array(z.string()).default([]),
    meta_title:       z.string().min(40).max(60),     // HARD — auditor §2.1
    meta_description: z.string().min(140).max(160),   // HARD — auditor §2.2
    h1: z.string(),
    schema_types: z.array(z.enum([
      'WebSite','Organization','Product','FAQPage','BreadcrumbList',
      'HowTo','Article','Person','ItemList',
      'AboutPage','ContactPage','CollectionPage',
    ])).default([]),
    // … path, og_image
  }),
});

// blog adds: hero_image_alt: z.string().min(20).max(160)   // HARD
//            excerpt: z.string().min(120).max(220)
//            status: z.enum(['draft','published']).default('draft')
//            (plus title, hero_image, category, date, read_time, author, updated_date, internal_links)
```

A content file that violates any constraint fails `astro build` with a clear error — the **writer agent** fixes the markdown, not the builder. **Never loosen the constraints to "ship" a violating file.** The full Zod (including the blog collection + all defaults) is the canonical version in [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md#content-collection-schemas-the-hf-7-fix).

---

## Step 5 — The locked SEO engine (sole `<head>` emitter)

`shared/seo-engine/SeoHead.astro` is the SOLE emitter of `<title>`, `<meta name="description">`, `<link rel="canonical">`, OG, Twitter, font preloads, theme color, and ALL JSON-LD. `tools/check-seo-lock.mjs` fails the build if any other component prints `application/ld+json` or `rel="canonical"`.

**Every page MUST:**

1. Import `BaseLayout` from `../layouts/BaseLayout.astro`.
2. Import schema factories from `../lib/schema` (a shim that calls `createSchemaBuilders(seoConfig)` — see tech-builder agent ["lib/schema.ts" section](../../../agents/iptv-tech-builder.md#srclibschemats)).
3. Read its content collection entry: `await getEntry('pages', 'iptv-anbieter')` — `meta_title`, `meta_description`, `h1`, `schema_types`, `primary_keyword`, `secondary_keywords` come from there (already length-constrained).
4. **Compose `schemaJsonLd` by iterating `schema_types` and calling the matching factory** (the HF-5 fix). Canonical pattern from `src/pages/blog/[...slug].astro`:
   ```ts
   const schemaJsonLd: Record<string, any>[] = [
     makeArticle({ title, description: excerpt, slug, image: hero_image, datePublished: date }),
     nestedBreadcrumb('Blog', '/blog/', title, url),
   ];
   if ((schema_types ?? []).includes('HowTo')) {
     // Derive steps from body's ## H2 headings + first paragraph under each.
     schemaJsonLd.push(makeHowTo({ name: h1, description: excerpt, steps }));
   }
   ```
5. Pass `title={meta_title}`, `description={meta_description}`, `schemaJsonLd`, `path`, and — for the LCP image — `preloadImage={{ href, imagesrcset, imagesizes, type: 'image/webp' }}` (built via `getImage` from `astro:assets`) to `BaseLayout`.

**Never:** hardcode `<title>` / `<meta name="description">` / `<link rel="canonical">` in any page or layout outside SeoHead. Never emit `<script type="application/ld+json">` from a page directly. Never interpolate schema as a template-literal string (XSS gate — the engine uses `set:html={JSON.stringify(schema)}`). Per-page schema composition detail per page role is in [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md#iptv-page-roles-what-to-scaffold) — don't restate.

---

## Step 6 — Schema-content alignment (2026 strict)

Google rejects FAQ/HowTo schema whose Q/A or step text is not on the page ([digitalapplied 2026](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026)). Enforce at the builder level:

- Every Q/A in `makeFAQPage(faqs)` MUST appear verbatim in the rendered FAQ accordion.
- Every `HowTo.step` MUST appear as a real `<ol>` step with matching `name` + `text`.
- `AggregateRating` is only emitted when ratings are visibly shown on the page.
- `Product.offers[].price` MUST match the visible price on the corresponding pricing card.

This is enforced by `iptv-seo-auditor` §3.2; the builder should never ship a page that fails it.

---

## Step 7 — Image rules (the HF-6 fix)

DE shipped raw `<img>` tags in 6 shared components — that's a hard fail for AI-crawler readability, CLS, and LCP. The rule is absolute:

- **Zero raw `<img>` in any `.astro` file.** Including `ProsePage.astro`, `BlogGrid.astro`, `Hero.astro`, `DeviceGrid.astro` — anywhere. The audit fails on a single occurrence.
- Every image: Astro's `<Image>` (or `<Picture>`) from `astro:assets` with `src`, `alt` (target-language, 5–15 words, no "image of"), `width`, `height`, `loading`, `fetchpriority`, `format: 'webp'`, and a `widths` array for srcset.
- **Hero / LCP:** `loading="eager"`, `fetchpriority="high"`, quality 58–65, and the image is preloaded via `BaseLayout.preloadImage` (built with `await getImage({ src, widths: [640, 960, 1280, 1600], sizes: '(min-width: 1152px) 1152px, 100vw', quality: 58, format: 'webp' })`). `SeoHead` emits `<link rel="preload" as="image" fetchpriority="high">` with matching srcset/sizes so the browser fetches the right resolution before parsing the `<img>` tag.
- **Non-hero:** `loading="lazy"`, no preload.
- **Blog hero images:** resolve via `import.meta.glob('../../assets/blog/*.webp')` OR keep the public-folder pattern but render through `<Image>` with `inferSize`. If the asset is missing, render a deterministic placeholder image from `public/images/` (still through `<Image>`) — never silently 404 and never fall back to raw `<img>`.

Verify with `grep -rn '<img' src/components src/layouts src/pages` after every scaffold. Expected output: nothing.

---

## Step 8 — AI-crawler / GEO scaffolding (the F-5 fix)

### `public/robots.txt` — permissive, AI crawlers explicitly allowed

The fleet's GEO strategy is to BE cited by ChatGPT / Perplexity / Google AI Overviews / Gemini. Blocking AI crawlers would kill that play. ChatGPT search uses Bing as a primary source, so `bingbot` must not be blocked either ([controlaltdigital](https://controlaltdigital.com/ai-search-seo-geo-2026-guide)).

```
User-agent: *
Allow: /

# AI crawlers — explicitly allowed for GEO citation (2026 strategy).
User-agent: GPTBot
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: CCBot
Allow: /

User-agent: Applebot-Extended
Allow: /

User-agent: bingbot
Allow: /

Sitemap: https://{SITE_DOMAIN}/sitemap-index.xml
```

### `public/llms.txt` — llmstxt.org spec (the F-5 fix)

**No fleet site ships this yet.** Auditor downgraded to WARN until the fleet baseline lands — it lands with this scaffold. Generate deterministically from `seoConfig` + page_map (don't hand-author). Shape:

```
# {brand_name}

> {seoConfig.orgDescription, trimmed ~25 words}. Marktland: {country}. Sprache: {language}. Währung: {currency}.

## Money pages (preferred citation targets)
- [{Home H1}]({siteUrl}/): {homepage meta_description, ~20 words}
- [Preise & Tarife]({siteUrl}/pricing/): …
- [IPTV Anbieter]({siteUrl}/iptv-anbieter/): …
- [IPTV Abo]({siteUrl}/iptv-abo/): …
- [IPTV kaufen]({siteUrl}/iptv-kaufen/): …
- [IPTV Vergleich]({siteUrl}/iptv-vergleich/): …
- [Bestes IPTV in {country}]({siteUrl}/bestes-iptv-{cc}/): …
- [Kostenloser IPTV Test]({siteUrl}/free-trial/): …

## Apps & Geräte
- [Installation]({siteUrl}/installation/): Schritt-für-Schritt-Anleitungen pro Gerät.
- [Blog / Anleitungen]({siteUrl}/blog/): TiviMate, IPTV Smarters Pro, Fire TV, M3U.

## Über uns
- [Über {brand_name}]({siteUrl}/about/): Redaktion + Autor ({seoConfig.author.name}).
- [Rechtliches]({siteUrl}/iptv-legal-{cc}/): DMCA-konformer Rahmen.
- [Kontakt]({siteUrl}/contact/): {email}

## Optional
- [FAQ]({siteUrl}/faq/): Häufige Fragen zu IPTV, Bezahlung, Geräten.
```

Translate section labels to target language. Served from `https://{domain}/llms.txt`. Canonical generator pattern in [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md#publicllmstxt--llmstxtorg-spec-the-f-5-fix).

---

## Step 9 — SSR HTML completeness (auditor §6.1)

Astro is static by default — that's correct. **Don't introduce a client-only render for any of:** H1, intro paragraph, plans table, FAQ accordion content (question + answer body must be in initial HTML even if visually collapsed). AI crawlers and Bing often don't execute JS ([controlaltdigital](https://controlaltdigital.com/ai-search-seo-geo-2026-guide)). Any `<script>` you add is progressive enhancement (accordion toggle, GSAP reveal), never initial content rendering.

**First 200 words rule (money pages):** the first 200 rendered words MUST contain the primary keyword + a 40–80-word atomic answer + a CTA. ~40–45% of AI citations come from the first 30% of a document ([controlaltdigital](https://controlaltdigital.com/ai-search-seo-geo-2026-guide)).

---

## Step 10 — Per-site class salt (footprint break)

Two fleet sites must NEVER share custom class names — Google's site-clustering can pattern-match them as a template network and demote the lot (auditor §1.6 + §10.5). A 2-character deterministic prefix from `fleet.config.yaml`'s `class_salt` field (e.g. DE = `kl`, NL = `au`) is applied to custom Tailwind tokens (`kl-mark-primary`), custom semantic classes (`text-kl-base-400`, `border-kl-rule`), and custom CSS vars in `global.css`. Generic Tailwind utilities (`flex`, `mt-6`, `grid`, `rounded`, …) are left alone — universal, not a fingerprint.

Run `node tools/salt-classes.mjs {cc}` once during scaffold (idempotent — marker comment in `global.css`). After build, `node tools/footprint-report.mjs` — expect custom-class Jaccard ≈ 0 vs every other live fleet site, a non-empty DOM tag-skeleton diff for Hero + Pricing, AND a different homepage `<section>` sequence vs every other live site. If any fail: switch the layout variant (`monolith` ↔ `aurora`, recorded in `brand.yaml`) before re-running. Two adjacent fleet sites should not pick the same variant.

---

## Step 11 — Required meta tags (emitted by SeoHead — builder NEVER hardcodes)

The locked engine emits, for every page: `<title>` + `<meta name="description">` (from props), `<link rel="canonical">` (production URL, no query params), OG (`og:title`, `og:description`, `og:image`, `og:url`, `og:type`, `og:locale` from `seoConfig.ogLocale` — `de_DE` / `nl_NL` / `fr_FR` etc.; competitors regularly ship `en_US` on non-English sites — never regress), Twitter (`summary_large_image`), `<meta name="robots" content="index,follow">`, `<html lang="{seoConfig.htmlLang}">`, font preloads from `seoConfig.fontPreloads` (woff2), theme color from `seoConfig.themeColor`, and the JSON-LD bundle (baseline `WebSite` + `Organization` auto-sitewide + per-page schemas from `schemaJsonLd` prop).

**No `hreflang` tags.** Single locale per domain — multilingual countries get one site per language (see [`00_build_iptv_site.md`](./00_build_iptv_site.md#hard-rules)).

---

## Step 12 — Performance budget (2026 CWV bar)

**INP < 200 ms** (replaced FID Q1 2026), **LCP < 2.5 s**, **CLS < 0.15** — saturated-niche hygiene bar ([linksurge 2026](https://blog.mean.ceo/startup-news-ai-search-dependence-google-rankings-2026/)). Homepage weight < 500 KB. Critical CSS inlined (`inlineStylesheets: 'always'`). Hero image preloaded (Step 7); no other render-blocking assets above the fold. **No `<script>` in `<head>`** beyond essential JSON-LD; head JS > 150 KB is a WARN. GSAP only on pages that use it — imported in client `<script>` tags, not BaseLayout; register ScrollTrigger; respect `prefers-reduced-motion`; clean up on `astro:after-swap`. Full animation patterns: [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md#animation-system-gsap). No third-party analytics at build time (operator adds post-launch).

---

## Step 13 — Robots & sitemap

`public/robots.txt` ships per Step 8 (AI crawlers allowed + sitemap reference). `@astrojs/sitemap` (Step 2) auto-emits `sitemap-index.xml` from page routes; drafts (`status: 'draft'`) excluded by `getStaticPaths` gate in `blog/[...slug].astro`. `public/llms.txt` ships per Step 8.

---

## Step 14 — Build & verify

```bash
pnpm --filter site-{cc} build
node /Users/boullamjaouad/Code/iptv-fleet/tools/check-seo-lock.mjs {existing_cc} {new_cc}
node /Users/boullamjaouad/Code/iptv-fleet/tools/footprint-report.mjs
```

Fail conditions (any = fix, don't patch over):

- `astro build` errors or content-collection Zod violations.
- `check-seo-lock.mjs` reports drift: any page outside `shared/seo-engine/` emits `<title>` / `<meta name="description">` / `<link rel="canonical">` / `application/ld+json`.
- `footprint-report.mjs` Jaccard > 0 vs another fleet site.
- `grep -rn '<img' src/components src/layouts src/pages` matches anything.
- `public/llms.txt` or `public/robots.txt` missing.

Spot-check `dist/index.html` directly: single `<h1>`, primary keyword in `<title>`, every type declared in homepage frontmatter `schema_types` emitted as a JSON-LD block, `og:locale` matches `seoConfig.ogLocale`.

Spot-check `dist/blog/{any-slug}/index.html`: `Person` schema present inside `Article.author` (the E-E-A-T differentiator most competitors miss — [eseospace 2026](https://eseospace.com/blog/how-ai-overviews-impact-seo-2026/)), visible "Von {seoConfig.author.name}" byline near the top, credentials bio block at the bottom.

---

## 2026 Critical Build Gates

The four HARD-FAIL classes the tech-builder owns. Each traces to a DE-audit finding + 2026 research:

- **HF-5 — Frontmatter `schema_types` drives schema emission.** Every page composing `schemaJsonLd` MUST iterate `schema_types` from frontmatter and call the matching `make*` factory. No silent drops. The blog layout especially: if `'HowTo'` is declared, `makeHowTo` MUST run. DE shipped guides declaring `HowTo` without calling `makeHowTo` → rich-result eligibility lost. Schema-content alignment is a 2026 enforcement priority ([digitalapplied 2026](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026)).
- **HF-6 — Zero raw `<img>` tags in any `.astro` file.** Every image goes through `<Image>` / `<Picture>` with `width`, `height`, `alt`, `loading`, `fetchpriority`, `format: 'webp'`. DE shipped raw `<img>` in 6 shared components → CLS spike + LCP regression + AI-crawler readability gap. INP < 200 ms + LCP < 2.5 s is the 2026 hygiene bar ([linksurge 2026](https://blog.mean.ceo/startup-news-ai-search-dependence-google-rankings-2026/)).
- **HF-7 — Zod length constraints strict.** Content collection enforces `meta_title.min(40).max(60)` AND `meta_description.min(140).max(160)` AND `hero_image_alt.min(20).max(160)`. Build errors on violation. DE shipped `z.string()` with no constraints → auditor caught 60+ char titles and 200+ char descriptions. Constraints AT THE SOURCE means bad content can't reach the page.
- **F-5 — `public/llms.txt` ships.** Generated deterministically from `seoConfig` + page_map per llmstxt.org spec. Lists money pages + free-trial + about + blog index + contact + FAQ. No fleet site ships this yet — fleet baseline lands with this scaffold. AI-crawler citation is first-class in 2026 ([controlaltdigital](https://controlaltdigital.com/ai-search-seo-geo-2026-guide)).

---

## Quality Gate — Pre-audit self-check

Run before handing off to `07_seo_audit.md`. Each item maps to an auditor HARD FAIL / FAIL — if you can't tick the box, the build will fail audit. (Full 14-point list in [`agents/iptv-tech-builder.md`](../../../agents/iptv-tech-builder.md#self-check-checklist-run-before-handing-back-to-the-auditor); summary here.)

1. `pnpm --filter site-{cc} build` succeeds with zero errors / zero warnings.
2. `node tools/check-seo-lock.mjs {existing_cc} {new_cc}` passes — SeoHead is the sole emitter (auditor §1.5).
3. `grep -rn '<img' src/components src/layouts src/pages` returns nothing (HF-6).
4. `src/content/config.ts` enforces the strict `.min/.max` Zod constraints on `meta_title`, `meta_description`, `hero_image_alt` (HF-7).
5. Every page's `schemaJsonLd` matches the `schema_types` declared in its frontmatter — verify by reading `dist/{page}/index.html` for the expected JSON-LD blocks (HF-5).
6. `public/llms.txt` exists, deterministic from `seoConfig` + page_map, translated to target language (F-5).
7. `public/robots.txt` explicitly allows `GPTBot`, `Google-Extended`, `PerplexityBot`, `ClaudeBot`, `CCBot`, `Applebot-Extended`, `bingbot`. No `Disallow: /` on any of them.
8. `node tools/salt-classes.mjs {cc}` ran; custom-class vocabulary is salt-prefixed.
9. `node tools/footprint-report.mjs` Jaccard ≈ 0; homepage section sequences differ across fleet; Hero + Pricing DOM skeletons differ.
10. For every money page: first 200 words of `dist/{page}/index.html` body contain primary keyword + atomic answer + CTA — all in initial SSR HTML (§6.1).
11. `Person` schema present on every blog post via `makeArticle({ author })` reading `seoConfig.author`; visible byline + credentials bio render in `dist/blog/{slug}/index.html`.
12. Every entry in `src/data/pricing.ts` `productOffers` has `priceCurrency` (from `seoConfig.currency`), `price`, `availability: 'https://schema.org/InStock'`. Visible pricing card prices match schema prices (§3.2).

If any check fails, fix it and re-run the SAME check that failed. Don't hand off to the auditor until every check is green.

---

## Output Handoff

The built `dist/` + source `src/` is ready for:

1. **`06_generate_images.md`** — if any hero image, OG image, or device mockup is still a placeholder. The writer surfaces missing assets as open-edges in step 04; the tech-builder must surface them again in this handoff (don't silently 404).
2. **`07_seo_audit.md`** — `iptv-seo-auditor` runs the full HARD-FAIL / FAIL / WARN pass against `dist/`. The pre-audit self-check above is intentionally a strict subset — the auditor still catches first-hand-testing language regressions, secondary-keyword density, banned-phrase DMCA framing, and competitor-bar gaps from `ranking_factors.json`.

If the auditor flags items, this workflow is re-entered as a **fix-it pass**: address only the failing items via the matching tech-builder section, re-run the SAME check that originally failed, hand back. Do not refactor passing items during a fix-it pass.
