# Workflow: Build IPTV Website (Orchestrator)

**Type:** Orchestrator SOP
**Role:** Lead architect coordinating specialist agents + tools
**Goal:** Produce a single-language, single-country, SEO-optimized IPTV subscription website built on Astro, ready for Cloudflare deployment, designed to rank #1 for commercial intent IPTV keywords in the target market.

---

## Required Inputs (collected before anything runs)

| Input | Example | Notes |
|---|---|---|
| `target_language` | `en`, `fr`, `de`, `es` | ISO 639-1. Single language only — no multilingual output. |
| `target_country` | `US`, `UK`, `FR`, `DE`, `CA` | ISO 3166-1 alpha-2. Drives DataForSEO location, currency, pricing, schema. |
| `brand_name` | `StreamVault IPTV` | |
| `domain` | `streamvault.tv` | |
| `usp` | 3–5 differentiators | e.g. "99.9% uptime", "24/7 support", "4K/8K", "20k+ channels" |
| `pricing` | plan table | 1m / 3m / 6m / 12m in local currency |
| `trial_offer` | `24h free trial` | |
| `contact` | email, WhatsApp, Telegram | No physical address required for IPTV. |
| `payment_methods` | stripe, crypto, paypal | |
| `design_personality` | bold / warm / sleek / energetic | Drives tech-builder decisions. |

If any input is missing, ask the user using `AskUserQuestion` **before** proceeding.

---

## Execution Order

Run the following workflows in strict sequence. Do **not** skip. Each step consumes the outputs of the previous ones.

1. **`01_keyword_research.md`** → target-country keyword universe (DataForSEO)
2. **`02_competitor_analysis.md`** → top 5 competitor teardown (Perplexity)
3. **`03_intent_mapping.md`** → keyword → page map (clustering)
4. **`04_write_content.md`** → all page copy via `iptv-seo-writer` agent (Anthropic)
5. **`05_build_astro.md`** → scaffold + components via `iptv-tech-builder` agent
6. **`06_generate_images.md`** → hero + OG + device mockups via Nanobana
7. **`07_seo_audit.md`** → `iptv-seo-auditor` agent full pass
8. **`08_deploy_cloudflare.md`** → production deploy + search console submission

Between steps: save intermediate artifacts to `.tmp/{target_country}_{target_language}/` so any step can be re-run without restarting the pipeline.

---

## Page Architecture (Locked)

Based on the "Plans + Channels + Devices" model:

```
/                         Homepage (hero + USPs + plans preview + trial CTA)
/pricing/                 Plans & pricing (primary conversion page)
/channels/                Channel lineup (searchable/filterable, country-specific)
/free-trial/              Trial signup (high-intent landing page)
/devices/                 Device hub (index of supported devices)
/devices/firestick/       Install guide + CTA
/devices/android/         Install guide + CTA
/devices/android-tv/      Install guide + CTA
/devices/ios-iphone/      Install guide + CTA
/devices/smart-tv/        Install guide + CTA (Samsung/LG)
/devices/mag-box/         Install guide + CTA
/devices/formuler/        Install guide + CTA
/faq/                     FAQ (schema-marked)
/blog/                    Blog index (topical authority)
/blog/[slug]/             Individual posts (from keyword research)
/contact/                 Contact + support channels
/about/                   Trust page (why choose us)
/legal/terms/
/legal/privacy/
/legal/refund/
```

Every device page and the homepage must link to `/pricing/` and `/free-trial/` above the fold.

---

## Tool Stack

**Already available:**
- **DataForSEO** — keyword volume, difficulty, SERP, related keywords (per country)
- **Nanobana** — hero, OG, device mockup image generation
- **Anthropic API** — content writing (Claude Opus 4.6)
- **Perplexity** — competitor analysis, fact-checking channel counts

**Recommended additions:**
- **SerpAPI** or **Scale SERP** — fallback/redundancy for DataForSEO SERPs
- **Google PageSpeed Insights API** — automated Lighthouse scoring in audit step
- **Cloudflare API** — programmatic deploy + DNS
- **pytrends** (free) — seasonal IPTV demand (sports seasons, PPV events)
- **Schema.org Validator API** — automated schema validation in audit
- **Stripe API** (if Stripe is used) — generate real checkout links during build

---

## Failure Handling

- **DataForSEO rate-limited** → fall back to cached `.tmp/keyword_cache.json` if fresh (<7 days), else queue and retry.
- **Perplexity returns thin competitor data** → widen seed query; if still thin, flag to user and let them paste top 5 URLs manually.
- **Content writer produces generic IPTV filler** → reject and re-prompt with stricter differentiator injection (see `04_write_content.md` guardrails).
- **Build fails** → diagnose, fix, rebuild. Never skip audit to force a pass.

Every failure that teaches something new **must** be written back into the relevant workflow file so it doesn't repeat.

---

## Hard Rules

1. **Single language, single country. Never emit `hreflang` alternates or `/en/`, `/fr/` prefixes.** The site is one locale.
2. **Never write generic IPTV filler** ("best IPTV service", "enjoy your favorite shows"). Every paragraph must be specific to the brand, country, and differentiators.
3. **Pricing is shown in the target country's local currency with correct symbol placement.**
4. **Channel counts and sports package names must be fact-checked via Perplexity** before being written as claims.
5. **No DMCA-sensitive claims** (e.g., "official Netflix", "licensed by ESPN"). The copy must describe the service without implying broadcaster licensing.
6. **Every page must have one primary CTA** — either "Start Free Trial" or "View Plans". Never both equally weighted.
7. **Multilingual countries get one site per language, not a combined site.** Some target countries have more than one official language. Before any workflow runs, the orchestrator must ask the user which language to target and build a single-locale site in that language only. Never combine languages on one domain.

### Multilingual-country reference

| Country | Language options | Typical default |
|---|---|---|
| BE (Belgium) | `nl` (Flemish, 60% of population), `fr` (Walloon), `de` (small eastern region) | `nl` for nationwide; `fr` for Brussels/Wallonia |
| CH (Switzerland) | `de` (65%), `fr` (22%), `it` (8%) | `de` for nationwide; pick regional language for targeted sites |
| LU (Luxembourg) | `fr`, `de`, `lb` | `fr` is safest for commercial IPTV |
| FI (Finland) | `fi` (90%), `sv` (5%) | `fi` |
| IE (Ireland) | `en` (100% effective commercial) | `en` |
| UA (Ukraine) | `uk` (primary), `ru` (declining) | `uk` |

For any country not listed here, use the most widely-spoken official language.

---

## Deliverables Checklist

- [ ] Astro project builds with zero errors
- [ ] All pages have unique title (50–60 chars) + meta description (140–160 chars)
- [ ] Schema: `Product` (plans), `FAQPage`, `BreadcrumbList`, `Organization`, `WebSite` with SearchAction
- [ ] Sitemap + robots.txt generated
- [ ] Lighthouse: Performance ≥90, SEO 100, Accessibility ≥90
- [ ] All images are WebP, lazy-loaded, with descriptive alt text in target language
- [ ] OG image + Twitter card set per page
- [ ] Trial CTA above the fold on homepage and every device page
- [ ] FAQ schema validates on Rich Results Test
- [ ] Deployed to Cloudflare Pages
- [ ] Sitemap submitted to Google Search Console
