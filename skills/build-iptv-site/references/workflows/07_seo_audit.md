# Workflow: SEO Audit (iptv-seo-auditor)

**Goal:** Full pre-launch audit of the built Astro project against a PASS/FAIL checklist. No launch until 100% PASS.

---

## Procedure

Spawn the `iptv-seo-auditor` agent. Pass the project root. The agent reads every generated file and returns a structured report:

```json
{
  "overall": "PASS | FAIL",
  "pass_count": 87,
  "fail_count": 3,
  "categories": {
    "technical_seo": [
      {"check": "canonical tag present", "status": "PASS", "file": "src/layouts/BaseLayout.astro:42"},
      {"check": "sitemap generated", "status": "FAIL", "file": "dist/sitemap-index.xml", "fix": "Re-run build"}
    ],
    "on_page": [...],
    "schema": [...],
    "content": [...],
    "performance": [...],
    "design_quality": [...],
    "iptv_specific": [...]
  }
}
```

If `overall: FAIL` → fix each FAIL, re-run the auditor. Never mark "launch ready" with open failures.

---

## Checklist (what the auditor validates)

### 1. Technical SEO
- [ ] Every page has a unique `<title>` 50–60 chars
- [ ] Every page has a unique `<meta description>` 140–160 chars
- [ ] Canonical tag on every page, absolute URL, matches path
- [ ] `robots.txt` present, allows crawl, references sitemap
- [ ] `sitemap-index.xml` generated, contains all public pages, no drafts/legal orphans
- [ ] **No `hreflang` tags anywhere** (single-locale rule)
- [ ] Correct `og:locale` tag matches `{target_language}_{target_country}`
- [ ] `lang` attribute on `<html>` matches `target_language`
- [ ] 404 page exists and is branded
- [ ] All internal links use relative paths or absolute site URL, no broken links
- [ ] No mixed content warnings (HTTPS only)

### 2. On-page optimization
- [ ] Primary keyword appears in: `<title>`, `<h1>`, first 100 words, URL slug (if applicable)
- [ ] Exactly one `<h1>` per page
- [ ] Heading hierarchy valid (no `<h3>` before `<h2>`)
- [ ] Images have descriptive alt text in target language, not "image" or empty
- [ ] Internal linking: homepage links to pricing + each device page; every device page links to pricing + trial; blog posts link to at least 2 money pages

### 3. Schema markup
- [ ] `Organization` schema on every page (via BaseLayout)
- [ ] `WebSite` + `SearchAction` on homepage
- [ ] `Product` + `Offer` schema on `/pricing/` for each plan, currency code matches country
- [ ] `HowTo` schema on every device install page, steps populated
- [ ] `FAQPage` on `/faq/` with every Q&A
- [ ] `Article` schema on every blog post, with author, datePublished, image
- [ ] `BreadcrumbList` on every non-homepage page
- [ ] All schema validates against Google Rich Results Test (run `tools/schema_validate.py`)
- [ ] No schema fields referencing data not visible on page

### 4. Content quality
- [ ] No banned filler phrases (from `04_write_content.md` banned list)
- [ ] No DMCA-risky phrases (broadcaster names with "official/licensed/free")
- [ ] Every page > 500 words (blog > 1200)
- [ ] No duplicate paragraphs across pages
- [ ] Currency formatted per locale (symbol position, decimal separator)
- [ ] Dates formatted per locale
- [ ] No English phrases in non-English site (except brand name)
- [ ] Readability: max 22 words/sentence average, max 3 sentences/paragraph average

### 5. Performance
- [ ] `npm run build` succeeds with zero warnings
- [ ] All images WebP, total homepage weight < 500 KB
- [ ] Hero image has `fetchpriority="high"` and preload hint
- [ ] Below-fold images `loading="lazy"`
- [ ] No render-blocking scripts (GSAP scoped to pages that need it)
- [ ] Critical CSS inlined
- [ ] PageSpeed Insights (via API): Performance ≥90, SEO 100, Accessibility ≥90, Best Practices ≥95
- [ ] LCP < 2.0s, CLS < 0.05, INP < 150ms

### 6. Design quality
- [ ] Homepage uses asymmetric hero (not centered text-over-image)
- [ ] Section backgrounds alternate for rhythm
- [ ] Section dividers between different backgrounds
- [ ] Colored shadows (not default gray)
- [ ] Gradient mesh behind hero + CTA sections
- [ ] Grain overlay present
- [ ] Hero H1 uses split-word reveal animation
- [ ] Primary CTA buttons have hover shine effect
- [ ] Animations respect `prefers-reduced-motion`
- [ ] Typography scale: hero H1 text-5xl mobile → text-7xl desktop
- [ ] Footer is 4-column, not a single row

### 7. IPTV-specific checks
- [ ] "Start Free Trial" (or equivalent) CTA above the fold on homepage and every device page
- [ ] Pricing page shows plans in local currency with local formatting
- [ ] Payment method logos present on pricing + trial pages (generic payment badge, no unlicensed logos)
- [ ] Every channel count / VOD count / uptime claim matches `verified_claims.json`
- [ ] No "licensed/official [broadcaster]" claims anywhere
- [ ] Trial terms clearly stated (duration, what's included, what happens after)
- [ ] Refund/cancellation policy page exists and is linked from footer
- [ ] Contact supports at least 2 channels (email + Telegram/WhatsApp typical for IPTV)
- [ ] Device pages each have a HowTo schema and a CTA back to pricing
- [ ] FAQ covers: legality question, refund, device compatibility, bitrate/quality, support hours

### 8. Accessibility
- [ ] All interactive elements keyboard-accessible
- [ ] Color contrast AA minimum (run `tools/a11y_check.py`)
- [ ] Form inputs have labels
- [ ] Skip-to-content link present
- [ ] No autoplay audio/video

---

## Tool Reference
- `tools/schema_validate.py` — schema.org validation
- `tools/a11y_check.py` — axe-core via Playwright
- `tools/pagespeed.py` — PSI API
- `tools/link_check.py` — internal link integrity

---

## Output
On PASS → handoff to `08_deploy_cloudflare.md`.
On FAIL → fix, re-audit, repeat until PASS.
