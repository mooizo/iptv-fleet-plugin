# Workflow: Content Generation (Anthropic API via iptv-seo-writer)

**Goal:** Write every word of the website in `target_language`, grounded in the page map and verified claims. No filler. No generic IPTV slop.

---

## Required Inputs
- `.tmp/{country}_{lang}/page_map.json`
- `.tmp/{country}_{lang}/verified_claims.json`
- `.tmp/{country}_{lang}/gap_analysis.md`
- Brand inputs from orchestrator (name, USPs, pricing, contact, payment methods, trial offer)

---

## Procedure

Spawn the **`iptv-seo-writer`** agent (see `agents/iptv-seo-writer.md`). Pass it the full page map plus brand inputs.

The writer produces `.tmp/{country}_{lang}/content/` with one file per page:
```
content/
  index.md
  pricing.md
  free-trial.md
  channels.md
  devices/index.md
  devices/firestick.md
  devices/android.md
  ...
  faq.md
  about.md
  blog/{slug}.md   (one per backlog post greenlit for launch)
```

Each content file follows this frontmatter schema:

```yaml
---
page_type: homepage | pricing | device | blog | ...
path: /
primary_keyword: "abonnement iptv"
secondary_keywords: ["iptv france", "iptv 4k"]
meta_title: "..." # 50–60 chars INCLUDING brand suffix
meta_description: "..." # 140–160 chars, one benefit + one CTA verb
h1: "..." # 4–8 words, aligns with primary keyword but isn't a literal match
og_image: /images/og-default.webp
schema_types: ["Product", "BreadcrumbList"]
---

# Body content in Markdown
# Structured as: Hero → USPs → Social proof → Benefits → FAQ → CTA
```

---

## Mandatory Copy Rules (enforce per page)

### Rules that apply everywhere
1. **Language purity.** 100% of body copy must be in `target_language`. No "bonjour" in an English site. No "hello" in a French site. Brand name exception only.
2. **No generic filler phrases.** Banned list:
   - "best iptv service"
   - "enjoy your favorite content"
   - "take your entertainment to the next level"
   - "immersive viewing experience"
   - "in this fast-paced world"
   - Any sentence that could appear on 10 other IPTV sites unchanged.
3. **Every paragraph must cite a specific differentiator or fact from `gap_analysis.md` or brand inputs.** If a paragraph could be deleted without losing brand specificity, delete it.
4. **Concrete numbers over adjectives.** "4K streaming at 25 Mbps bitrate" beats "ultra-high-quality streaming". Only claim numbers that appear in `verified_claims.json`.
5. **Currency formatting** must match `target_country` convention:
   - `US` / `UK`: `$9.99` / `£9.99` (symbol before)
   - `FR` / `DE`: `9,99 €` / `9,99 €` (symbol after, comma decimal)
   - Never mix conventions on the same page.
6. **Dates & numbers** must use the target locale's formatting (thousand separators, date order).
7. **No DMCA red flags.** Banned phrases:
   - "licensed by [broadcaster]"
   - "official [Netflix/Disney+/etc]"
   - "watch [copyrighted show name] for free"
   - Use descriptive neutral framing: "access to sports channels" / "wide selection of live TV"

### Homepage specifics
- **Hero H1:** 4–8 words. Never a literal keyword match.
- **Hero subhead:** one sentence, states the primary differentiator.
- **Primary CTA above fold:** "Start Free Trial" (if trial offered) OR "View Plans".
- **USP strip:** exactly 3 items, each <10 words.
- **Plans preview:** show 3 plans with prices, link to `/pricing/` for full table.
- **Social proof:** at least one real testimonial OR one trust signal (uptime, support hours).
- **Bottom FAQ:** exactly 5 questions pulled from DataForSEO "people also ask".

### Pricing page specifics
- Plans table with: name, duration, price, per-month equivalent, features list, CTA.
- Payment methods row (icons + labels).
- Money-back / refund note if applicable.
- 3-question FAQ specific to billing/cancellation.
- Schema: `Product` + `Offer` per plan.

### Device pages specifics
- H1 format: `How to Install IPTV on {Device} in {Year}` (translated to target language).
- Step-by-step numbered install instructions (5–9 steps).
- Callout box for prerequisites (app name, subscription required).
- Embedded plans CTA mid-page.
- Troubleshooting section (3 common issues + fixes).
- Schema: `HowTo` + `BreadcrumbList`.

### Blog post specifics
- Minimum 1,200 words, maximum 2,500 words.
- At least 3 H2 subheadings.
- Internal link to `/pricing/` once + one device page once.
- Image with keyword-rich alt text.
- Author: `{brand_name} Editorial` (not "admin").
- Schema: `Article` + `BreadcrumbList`.

### FAQ page specifics
- 15–25 questions.
- Answers 40–80 words each.
- Organized in 3 sections: "About the service", "Setup & devices", "Billing & support".
- Schema: `FAQPage` with every Q&A.

---

## Writer Invocation Template

```
Agent: iptv-seo-writer
Task: Write all page content for {brand_name}, a direct-to-consumer IPTV subscription service targeting {country_name}, in {language_name}.

Page map: {path to page_map.json}
Verified claims: {path to verified_claims.json}
Gap analysis: {path to gap_analysis.md}
Brand inputs: {path to brand_inputs.json}

Deliver one markdown file per page per the schema above. Reject your own output and retry if any file contains phrases from the banned list. Do not write a final report — just the files.
```

---

## Quality Gate

Before passing content to the tech-builder, run `tools/content_linter.py` which checks:
- [ ] Every file has all frontmatter fields
- [ ] Title length 50–60 chars
- [ ] Meta description length 140–160 chars
- [ ] No banned phrases present
- [ ] Currency formatting matches locale
- [ ] Primary keyword appears in H1, first 100 words, and at least one H2
- [ ] No duplicate H1 across pages
- [ ] Language detection matches `target_language` with >99% confidence

If any file fails, re-invoke writer with the specific failures listed.

---

## Learned Constraints
- Claude Opus 4.6 will occasionally produce generic content on the first pass even with strict instructions. Always lint + retry. Expect 10–20% of files to need one revision.
- For languages with low training data (e.g. Albanian, Georgian), quality drops — have a native speaker review before launch.
- IPTV copy in English tends to drift toward black-hat framing ("unlock everything", "no restrictions"). Actively steer away from this — it tanks brand trust AND invites DMCA complaints.

---

## Output Handoff
Pass `.tmp/{country}_{lang}/content/` to `05_build_astro.md`.
