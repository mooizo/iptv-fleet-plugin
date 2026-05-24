# Content Frontmatter Schema

Every markdown file in `src/content/pages/` and `src/content/blog/` uses YAML frontmatter that maps to the Zod schemas in `assets/content-config.ts`. The `iptv-seo-writer` agent emits files in this exact shape — any deviation fails the Astro build.

## Pages collection schema

```yaml
---
page_type: homepage | pricing | trial | channels | devices_index | device | installation | faq | about | contact | blog
path: /
primary_keyword: "abonnement iptv"
secondary_keywords:
  - "iptv france"
  - "iptv 4k"
  - "meilleur iptv"
meta_title: "..."              # 50–60 chars INCLUDING brand suffix
meta_description: "..."        # 140–160 chars, one benefit + one CTA verb
h1: "..."                      # 4–8 words, aligns with primary_keyword but NOT a literal match
og_image: /images/og-default.webp
schema_types:
  - Product
  - BreadcrumbList
---

# Body content in Markdown
# Structure: Hero → USPs → Social proof → Benefits → FAQ → CTA
```

### Field rules

| Field | Required | Constraint |
|---|---|---|
| `page_type` | yes | Must match one of the 11 enum values |
| `path` | yes | Must match the file's URL path |
| `primary_keyword` | yes | Single phrase, target language, lowercased |
| `secondary_keywords` | no (default `[]`) | 2–5 related phrases |
| `meta_title` | yes | **50–60 chars** — linter fails outside this range |
| `meta_description` | yes | **140–160 chars** — linter fails outside this range |
| `h1` | yes | 4–8 words, NOT a literal keyword match |
| `og_image` | no | Defaults to `/images/og-default.webp`; override for pages with unique hero |
| `schema_types` | no (default `[]`) | Array of Schema.org types to inject |

### meta_title suffix convention

Always ends with ` · {brand_name}` or `| {brand_name}`. Example:
- ✅ `IPTV Abonnement 4K — 20 000+ Chaînes · IPTV Éclair` (58 chars)
- ❌ `IPTV France` (too short, no brand)

### h1 ≠ keyword rule

The H1 must relate to the primary keyword but never match it literally. Example:
- `primary_keyword: "abonnement iptv"`
- ❌ H1: `Abonnement IPTV` (literal match — reads spammy, Google downweights)
- ✅ H1: `Chaînes sans limites en 4K` (evocative, keyword-semantic not keyword-match)

## Blog collection schema

```yaml
---
title: "Meilleur IPTV France : Guide 2026"
excerpt: "Courte description 120–160 caractères pour le feed et les cards."
primary_keyword: "meilleur iptv france"
secondary_keywords:
  - "iptv france avis"
  - "comparatif iptv"
meta_title: "..."              # 50–60 chars
meta_description: "..."        # 140–160 chars
h1: "..."                      # Can be the article title, no 4–8 word limit
hero_image: /images/blog/meilleur-iptv-france.webp
hero_image_alt: "Interface IPTV sur Smart TV"
category: "Gids"               # Default "Gids" (Dutch) — override per language
date: 2026-04-11
read_time: "6 min"             # Default "6 min"
schema_types:
  - Article
  - BreadcrumbList
---

# Body in Markdown, 1200–2500 words, ≥3 H2s
```

### Blog-specific rules

| Field | Rule |
|---|---|
| `excerpt` | 120–160 chars, shown in BlogGrid cards |
| `hero_image` | Always WebP, always in `/images/blog/`, always generated in step 06 |
| `hero_image_alt` | Target-language, keyword-aware, descriptive |
| `category` | Translate per language: NL `Gids`, DE `Leitfaden`, FR `Guide`, ES `Guía`, IT `Guida` |
| `date` | ISO format (`YYYY-MM-DD`), auto-coerced to Date |
| `read_time` | Human-readable string, default `6 min` but adjust for actual word count (200 wpm) |
| `schema_types` | Defaults to `["Article", "BreadcrumbList"]` — don't remove these |

## Validation chain

1. **Astro build time** — Zod schema in `content-config.ts` fails the build on any schema mismatch
2. **Lint time** (before build) — `tools/content_linter.py` checks:
   - Title/description length
   - Banned phrases (`banned-phrases-dmca.md`)
   - Currency format per locale
   - Primary keyword in H1 + first 100 words + ≥1 H2
   - No duplicate H1 across pages
   - Language detection ≥99% confidence (`lingua-language-detector`)
3. **SEO audit** (step 07) — validates rendered JSON-LD against schema.org

## Writer agent frontmatter cheat sheet

When invoking `iptv-seo-writer`, pass the exact schema above in the system prompt along with:
- Page map path (`page_map.json`)
- Verified claims path (`verified_claims.json`)
- Gap analysis path (`gap_analysis.md`)
- Brand inputs (name, USPs, pricing, contact, payment methods)

The agent should emit one file per page, no final report, no commentary.
