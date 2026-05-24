---
name: build-iptv-site
description: Build a production-grade IPTV subscription website (Astro + Tailwind + Cloudflare Pages) for a specific country/language. Use when the user asks to build, scaffold, launch, or clone an IPTV site — including phrases like "new IPTV site", "IPTV Germany/France/UK/Spain/Italy", "IPTV Helder clone", "another IPTV market", "build iptv website", "launch streaming subscription site", "iptv landing page". NOT for generic service-business sites — use `build-website` for those.
---

# Build IPTV Site

A complete, opinionated pipeline for launching a single-language, single-country IPTV subscription website. Distilled from the IPTV Helder (iptvhelder.nl) build.

## What this skill gives you

- A locked 8-step WAT pipeline (Workflows → Agents → Tools) for research → content → build → audit → deploy
- IPTV-niche seed keywords, banned phrases, DMCA-safe framing rules
- Brand token system (Tailwind config + Plus Jakarta Sans) ready to re-skin per brand
- A proven 9-page architecture that maps to all commercial IPTV intent
- 6 IPTV-specific Astro components (ChannelGrid, DeviceGrid, PricingCards, ComparisonTable, SportsLeaguesGrid, PaymentMethodsStrip)
- BaseLayout with full SEO (OG, Twitter, JSON-LD Organization + WebSite, canonical, favicons, font preload)
- Content collection Zod schemas for `pages` + `blog`
- Competitor scan gotchas (Firecrawl / Perplexity / Claude pipeline learnings)

## When to invoke

**Use this skill when:**
- Building a new IPTV site for a country/language combination not yet launched
- Cloning the IPTV Helder pattern for a new brand
- Running any of the 8 pipeline steps in isolation (keyword research, competitor scan, content writing, SEO audit)

**Don't use this skill for:**
- Editing the existing iptvhelder.nl site (just work directly in `astro-site/`)
- Non-IPTV service businesses (use `build-website` instead)
- Multilingual single-domain sites — this pipeline is **strictly single-locale per domain**

## Phase 0 — Read fleet.config.yaml FIRST (always)

Before asking ANY Phase A questions, **always** check `iptv-fleet/fleet.config.yaml`:

```bash
# from monorepo root
cat ./fleet.config.yaml
```

For the target country (passed as `{cc}`), look up `countries.{cc}` and read every populated field. **Only ask Phase A questions for fields that are missing or empty.** Never re-ask a question whose answer is already in the config.

After Phase A, write any newly-collected answers BACK to `fleet.config.yaml` immediately so the next run won't re-ask. Use `git add fleet.config.yaml && git commit -m "fleet({cc}): branding inputs"`.

## Required inputs (collect before step 1)

The plugin's `/iptv-new {cc}` command and the orchestrator skill normally fill these from `fleet.config.yaml`. If you're running this skill standalone (no plugin), you collect them via `AskUserQuestion` and write them to `fleet.config.yaml.countries.{cc}`.

| Input | Example | Where it lives in fleet.config |
|---|---|---|
| `target_country` | ISO-3166 alpha-2, e.g. `DE` | `countries.{cc}.country` |
| `target_language` | ISO-639-1, e.g. `de` | `countries.{cc}.language` |
| `brand_name` | `IPTV Klar` | `countries.{cc}.brand_name` |
| `domain` | `iptvklar.de` | `countries.{cc}.domain` |
| `usp` | 3–5 differentiators | `countries.{cc}.usp[]` |
| `pricing` | plans in local currency | `countries.{cc}.pricing` (or `default`) |
| `trial_offer` | `24h free trial` | `countries.{cc}.trial_offer` |
| `contact` | email + WhatsApp/Telegram | `countries.{cc}.contact.{email,whatsapp}` |
| `payment_methods` | stripe / crypto / SEPA / iDEAL | `countries.{cc}.payment_methods[]` |

If any are missing, ask via `AskUserQuestion` before starting. Multilingual countries (BE, CH, LU, FI) — pick **one** language per build; see `references/workflows/00_build_iptv_site.md` for the table.

## Where things live in the iptv-fleet monorepo

- **Tools (Python scripts)** → `iptv-fleet/tools/` (NOT inside this skill — the skill folder is just instructions)
- **Shared components** → `iptv-fleet/shared/astro-base/` (BaseLayout, 6 IPTV components, Tailwind base)
- **Per-country site** → `iptv-fleet/sites/{cc}/`
- **Pipeline intermediates** → `iptv-fleet/.tmp/{COUNTRY}_{lang}/`
- **Cached SEO data** → `~/.claude/skills/seo-data-store/data/{COUNTRY}/`
- **Source of truth for fleet state** → `iptv-fleet/fleet.config.yaml`

---

## Phase A — Branding questionnaire (run BEFORE step 1)

Before any research or building begins, collect the brand's visual identity. Ask the user each of these questions via `AskUserQuestion`. Do NOT proceed to step 1 until all branding inputs are confirmed.

### Questions to ask

**1. Color palette**
> "What are your brand colors? I need 3 hex values:
> - **Primary** (headings, dark bands, nav) — e.g. `#204289`
> - **Secondary** (CTAs, buttons, highlights) — e.g. `#0089F7`
> - **Accent** (links, icon tints, active states) — e.g. `#286CF5`
>
> You can also share a screenshot, Figma link, or Coolors palette URL."

If the user provides a screenshot or image, extract the hex values from it. If they only provide 1–2 colors, derive the missing ones (darken primary for accent, brighten for secondary — keep WCAG AA on white).

**2. Font choice**
> "What font should the site use? Options:
> - **Plus Jakarta Sans** (default — clean, modern, excellent for IPTV)
> - **Inter** (neutral, highly legible)
> - **DM Sans** (geometric, tech-forward)
> - **Outfit** (rounded, friendly)
> - A custom font (provide a Google Fonts name or upload woff2 files)
>
> If unsure, I'll use Plus Jakarta Sans."

**3. Design personality**
> "Which design personality fits your brand?
> - **Professional** — clean lines, muted tones, corporate trust (default)
> - **Bold** — high contrast, strong CTAs, punchy headlines
> - **Sleek** — dark mode vibes, gradient accents, glass effects
> - **Energetic** — vibrant colors, sports-forward, dynamic layouts
> - **Warm** — rounded corners, friendly tones, approachable"

This drives component styling decisions in step 05 (tech-builder). Map to:
- Professional → flat shadows, 5px radius, muted neutrals
- Bold → strong shadows, high-contrast cards, 8px radius
- Sleek → dark sections, glass-card effect, glow shadows, 10px radius
- Energetic → bright accent pops, sport imagery emphasis, animated stats
- Warm → softer shadows, 12px radius, warm-tinted neutrals (override ink scale)

**4. Logo**
> "Do you have a logo? Share it as:
> - SVG (preferred for crisp rendering at any size)
> - PNG with transparent background (minimum 400px wide)
> - Or describe what you want and I'll create a text-based logo from the brand name."

**5. Reference sites (optional but valuable)**
> "Are there any websites (IPTV or otherwise) whose look/feel you want to match or take inspiration from? Share 1–3 URLs."

If the user provides reference URLs, use Playwright to screenshot them and extract design patterns (layout, color usage, spacing, component styles) to inform step 05.

### What to do with the answers

Save all branding inputs to `.tmp/{country}_{lang}/brand_inputs.json`:

```json
{
  "brand_name": "IPTV Klar",
  "domain": "iptvklar.de",
  "palette": {
    "primary": "#1A3A6E",
    "secondary": "#FF6B35",
    "accent": "#4A90D9"
  },
  "font": "Inter",
  "design_personality": "bold",
  "logo": "svg path or description",
  "reference_sites": ["https://example.com"],
  "wcag_validated": true
}
```

Before saving, **always validate**:
- Run WCAG AA contrast check on `secondary` against white (`#FFFFFF`). If it fails (ratio < 4.5:1), darken it and tell the user: "I darkened your secondary from X to Y to pass accessibility — here's the comparison."
- If the font isn't Plus Jakarta Sans, check it's available on Google Fonts or the user has provided woff2 files. Download/prepare the font files for `public/fonts/` and update the `BaseLayout.astro` preload tags accordingly.
- Regenerate the `ink` / `flame` / `coral` Tailwind scales around the user's palette (keep the same lightness curves from `references/brand-system.md` but shift the hue).

---

## Phase B — Competitor & keyword validation (run BEFORE step 1)

After branding is locked, collect the user's competitive intelligence and validate it before the automated research pipeline runs. This saves API costs and catches bad inputs early.

> **Step 0 — ALWAYS check seo-data-store cache first.** Before any DataForSEO/SEMrush spend, check `~/.claude/skills/seo-data-store/data/{COUNTRY}/latest.json`. If it exists AND `last_updated` is ≤30 days old, use the cached data and skip steps 01/02's external API calls entirely. The cache is the single source of truth for Semrush data. See `~/.claude/skills/seo-data-store/docs/integration-build-iptv-site.md` for the consumption contract. If cache is missing/stale, invoke the `seo-data-store` skill first to refresh it, THEN proceed.

> **Optional SEMrush enrichment.** If the SEMrush MCP is connected and the user has API units available, run workflow `references/workflows/01a_semrush_enrichment.md` AFTER step 01. It layers authoritative SERP, keyword-difficulty, and competitor-keyword data onto the DataForSEO baseline. Read `references/semrush_budget_rules.md` first — it defines lead-vs-tier-2 market gating and the 500u/wk cap. Skip 01a entirely if SEMrush is unavailable; the pipeline still works end-to-end.

### Questions to ask

**1. Top competitors**
> "Who are your top 3–5 competitors in this market? Provide their domain names.
> - Example: `iptvsnederland.com`, `deiptv.nl`, `omniptv.com`
>
> If you're not sure, I'll discover them automatically in step 02 — but known competitors save time and produce better gap analysis."

**2. Target keywords**
> "Do you already have target keywords in mind? List your top 5–10 keywords you want to rank for.
> - Example: `iptv deutschland`, `iptv kaufen`, `iptv 4k`, `iptv firestick`
>
> If you're not sure, I'll generate the full keyword universe in step 01 — but seeds you provide will be prioritized."

### What to do with the answers

**If the user provides competitors:**
1. Save them to `.tmp/{country}_{lang}/user_competitors.json`
2. In step 02, **use these as the seed list** instead of (or merged with) the SERP-frequency method. Still validate that they're real IPTV providers (not aggregators/review blogs) using the blocklist.
3. If fewer than 5, top up from SERP-frequency discovery to reach 5.

**If the user provides keywords:**
1. **Validate each keyword via DataForSEO** — pull search volume, keyword difficulty, and CPC for the exact phrase in the target country/language:
   ```bash
   python tools/dataforseo_keyword_research.py --country DE --language de --validate-only --keywords "iptv deutschland,iptv kaufen,iptv 4k"
   ```
2. Present the validation results in a table:
   ```
   | Keyword             | Volume | KD  | CPC   | Verdict         |
   |---------------------|--------|-----|-------|-----------------|
   | iptv deutschland    | 8,100  | 42  | €1.80 | Strong — keep   |
   | iptv kaufen         | 4,400  | 38  | €2.10 | Strong — keep   |
   | iptv fire tv stick  | 1,200  | 22  | €0.90 | Good long-tail  |
   | iptv test           | 90     | 15  | €0.30 | Low vol — skip? |
   ```
3. **Suggest additional keyword opportunities** by querying Perplexity for the top trending IPTV search terms in the target market that the user may have missed:
   ```
   Perplexity prompt: "What are the most popular IPTV-related search queries
   in {country_name} right now? Include device-specific, sports-specific,
   and price-comparison queries. Focus on terms people actually search for
   when looking to buy an IPTV subscription."
   ```
4. Present suggested additions to the user for approval before adding to the seed list.
5. Save the validated + approved keyword list to `.tmp/{country}_{lang}/user_keywords.json`. Step 01 will **merge these as priority seeds** (weight multiplier 3.5×) alongside the standard seed list from `references/seed-keywords.md`.

**If the user provides neither:**
- Skip validation, proceed to step 01/02 which will discover everything automatically. This is fine — just slightly less targeted.

**If the user provides a Perplexity-only request** (e.g. "just find me the best keywords"):
- Run only the Perplexity discovery call (no DataForSEO spend), present suggestions, get approval, then proceed to step 01 with those as seeds.

---

## Execution order (strict)

After Phase A (branding) and Phase B (competitor/keyword validation) are complete, run the 8 workflows in `references/workflows/` in sequence. Each step consumes the previous step's outputs written to `.tmp/{country}_{lang}/`:

0. **Phase A** → `brand_inputs.json` (palette, font, personality, logo, references)
0. **Phase B** → `user_competitors.json` + `user_keywords.json` (validated seeds)
1. `01_keyword_research.md` → DataForSEO keyword universe (merges user_keywords.json as priority seeds)
1a. `01a_semrush_enrichment.md` → **Optional.** SEMrush layer for SERP, KD, competitor keywords. Skip if SEMrush unavailable. Read `references/semrush_budget_rules.md` first.
2. `02_competitor_analysis.md` → Firecrawl + Perplexity + Claude teardown (merges user_competitors.json as seed list)
3. `03_intent_mapping.md` → keyword → page_map clustering
4. `04_write_content.md` → `iptv-seo-writer` agent produces all markdown
5. `05_build_astro.md` → `iptv-tech-builder` agent scaffolds Astro (reads brand_inputs.json for palette, font, personality)
6. `06_generate_images.md` → Gemini 2.5 Flash Image (hero, OG, device mockups — uses brand palette)
7. `07_seo_audit.md` → `iptv-seo-auditor` full audit
8. `08_deploy_cloudflare.md` → Pages deploy + Search Console
9. `09_post_launch_ranking_loop.md` → **Standing workflow.** Runs monthly per active country (GSC + SEMrush refresh + content recs). ~100u/mo.

Never skip steps 1–8. Never reorder. Step 1a is optional. Step 9 is standing/monthly. Every intermediate artifact lives in `.tmp/{country}_{lang}/` so any step can be re-run in isolation.

## Before touching code

Always read these two references first:
- `references/brand-system.md` — palette, fonts, tokens
- `references/page-architecture.md` — the 9 locked page types

## Hard rules (non-negotiable)

1. **Single locale only** — never emit `hreflang` or `/en/` prefixes.
2. **No DMCA red flags** — no "official Netflix", no "licensed by ESPN", no broadcaster logo lockups. See `references/banned-phrases-dmca.md`.
3. **Every numeric claim cites `verified_claims.json`** from step 02. Never fabricate channel counts, uptime, or pricing.
4. **Language purity** — 100% target language, enforced by `tools/content_linter.py` + `lingua-language-detector`.
5. **One primary CTA per page** — "Start Free Trial" OR "View Plans", never both equally weighted.
6. **Locale currency formatting** — `$9.99` (US/UK), `9,99 €` (FR/DE/ES). Never mix.

## Assets to copy verbatim into new project

From `assets/`:
- `tailwind.config.iptv.mjs` → `{project}/tailwind.config.mjs` (re-palette per brand)
- `BaseLayout.astro` → `{project}/src/layouts/BaseLayout.astro`
- `content-config.ts` → `{project}/src/content/config.ts`
- `public/_headers`, `public/_redirects`, `public/robots.txt` → `{project}/public/`
- `components/*.astro` → `{project}/src/components/` (IPTV-specific only — regenerate generic Header/Footer/Hero per brand)

## Tool scripts

Python tools live in the source repo (not copied into this skill). See `scripts/README.md` for the inventory + invocation. All tools read credentials from `.env` and write intermediates to `.tmp/{country}_{lang}/`.

## Memory hooks

This skill pairs with 5 durable memory entries in the source project's memory folder:
- `project_wat_framework.md` — workflows/agents/tools separation
- `project_iptv_page_architecture.md` — 9 locked page types
- `feedback_competitor_scan_gotchas.md` — Firecrawl/Perplexity/Claude pitfalls
- `feedback_iptv_content_rules.md` — DMCA framing + claim citation
- `reference_iptv_skill.md` — pointer to this skill

## Deliverables checklist (from workflow 00)

- [ ] Astro builds with zero errors
- [ ] Unique title (50–60 chars) + meta description (140–160 chars) per page
- [ ] Schema: Product/Offer (plans), FAQPage, BreadcrumbList, Organization, WebSite+SearchAction, HowTo (device pages), Article (blog)
- [ ] Sitemap + robots.txt
- [ ] Lighthouse: Performance ≥90, SEO 100, Accessibility ≥90
- [ ] All images WebP, lazy-loaded, target-language alt text
- [ ] OG + Twitter cards per page
- [ ] Trial CTA above fold on homepage + every device page
- [ ] FAQ schema passes Rich Results Test
- [ ] Deployed to Cloudflare Pages
- [ ] Sitemap submitted to Google Search Console
