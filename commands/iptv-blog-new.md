---
description: Draft a new blog post for a country site, picking the highest-opportunity topic from frozen Semrush data. Saves as draft for Decap CMS review. Usage:/iptv-blog-new {COUNTRY_CODE} [topic]
argument-hint: "{country-code} [optional: topic in quotes, e.g. \"iptv eredivisie 2026\"]"
---

# /iptv-blog-new {country} [topic]

Drafts a 1,500–2,000-word blog post for `iptvhelder.{country}` (or relevant fleet brand). Pulls a real content cluster from frozen Semrush data, picks an uncovered opportunity keyword (or honors the topic you passed), spawns the `iptv-seo-writer` agent in Blog Mode, saves the result as a **draft** in the site's content collection.

You then review + publish via Decap CMS at `https://{domain}/admin/`.

**Touches Semrush API: NO.** Reads cached JSON.
**Auto-publishes: NO.** All outputs are `status: draft` for human review.

## What to do

### 1. Validate inputs
- Argument 1 (`{cc}`) is required, ISO-3166 alpha-2. Normalize to lowercase for paths, uppercase for data folder.
- Argument 2 (`{topic}`) is optional. If passed, it's the explicit topic to write about. If omitted, the agent picks via opportunity scoring.
- Verify `sites/{cc-lower}/` exists under the monorepo. If not, error: "Site doesn't exist yet — run `/iptv-new {cc}` first."

### 2. Verify frozen Semrush data exists

Required files in `~/.claude/skills/seo-data-store/data/{CC-UPPER}/`:
- `keywords_*.json` (any dated file matching the pattern)
- `keyword_gap_*.json`
- `topic_briefs_*.json`
- `paa_questions_*.json`

If any of these is missing, error and instruct:
> "Frozen Semrush data missing for {CC}. Run `/iptv-seo-ingest-{cc-lower}` first to ingest your manual Semrush CSV exports."

Read the latest-dated file of each kind (e.g. `keywords_2026-05-26.json`). Resolve the exact paths once at the top — pass them to the writer agent verbatim.

### 3. Inventory existing coverage

Glob `sites/{cc-lower}/src/content/blog/*.md` and `sites/{cc-lower}/src/content/pages/*.md`. For each file:
- Parse YAML frontmatter (simple regex on `^primary_keyword:` and `^secondary_keywords:` lines is enough)
- Collect every `primary_keyword` + each item under `secondary_keywords:`
- Lowercase + trim each token, store in a `covered_set: Set<string>`

Print the covered set count: "Already covered: N keywords across M existing posts."

### 4. Pick the cluster

**Branch A — User passed a topic:**
- Lowercase the topic
- Search `topic_briefs.json` `topics[].seed` for a fuzzy match (substring or token overlap ≥ 50%)
- If no match: error "Topic '{topic}' not found in topic_briefs. Either pass an existing topic from topic_briefs.json or omit the argument to auto-pick."
- If matched: use that topic + the matching `keyword_gap` entry whose primary keyword overlaps with the topic seed

**Branch B — No topic passed (auto-pick):**
- Load `keyword_gap.json`. Sort `gaps[]` by `opportunity_score` desc.
- Walk the sorted list. For each entry, lowercase its `keyword`:
  - Skip if `keyword` is in `covered_set`
  - Skip if any `covered_set` entry is a substring of `keyword` or vice versa (avoids near-duplicate posts)
  - Take the first survivor
- If no survivor in top 100 entries, fall back to `keywords.json` (sort by volume desc, same filter)
- Print: "Auto-picked: '{keyword}' — opportunity_score={N}, volume={V}, KD={K}"

### 5. Build the content brief

A structured object the writer agent receives. Build it from the frozen data:

```json
{
  "primary_keyword": "iptv eredivisie 2026",
  "volume": 720,
  "kd": 32,
  "intent": "transactional",
  "opportunity_score": 979.2,
  "secondary_keywords": [
    "eredivisie streaming",
    "eredivisie kijken iptv",
    "iptv voetbal nederland",
    ...
  ],
  "paa_questions": [
    "Kan ik Eredivisie kijken via IPTV?",
    "Welke IPTV-aanbieder heeft Eredivisie?",
    ...
  ],
  "subtopics": [
    {"title": "Eredivisie kijken: legaal kader", "questions": [...]},
    {"title": "Welke pakketten bevatten Eredivisie", "questions": [...]},
    ...
  ],
  "internal_link_candidates": [
    "/pricing/",
    "/iptv-nederland/",
    "/installatie/",
    "/free-trial/",
    "/blog/iptv-vergelijken-nederland/"
  ],
  "competitors_ranking_for_this": [
    {"domain": "iptvsnederland.com", "position": 3, "url": "..."},
    ...
  ]
}
```

Sources:
- `primary_keyword`, `volume`, `kd`, `intent`, `opportunity_score`, `competitors_ranking_for_this` ← `keyword_gap.json` entry
- `secondary_keywords[]` ← `keywords.json` entries where `seed` matches the picked topic OR keyword shares ≥1 token with primary
- `paa_questions[]` ← `paa_questions.json` `questions[]` filtered where `keyword` shares ≥1 token with primary
- `subtopics[]` ← `topic_briefs.json` `topics[].subtopics[]` for the matched topic
- `internal_link_candidates[]` ← inventoried existing pages from step 3, ranked by topical relevance (token overlap with primary keyword)

### 6. Compute the slug

`slug = kebab-case(primary_keyword)`. Strip diacritics, replace spaces with `-`, lowercase. E.g. `"iptv eredivisie 2026"` → `iptv-eredivisie-2026`.

Verify the file doesn't already exist at `sites/{cc-lower}/src/content/blog/{slug}.md`. If it does, append `-2`, `-3`, etc. (shouldn't happen if step 3 worked, but defensive).

### 7. Spawn the writer agent

Use the Task tool to spawn `iptv-seo-writer` with this prompt structure:

```
You're writing in BLOG MODE per the "Blog Mode (vs Page Mode)" section of your instructions.

TARGET FILE: sites/{cc-lower}/src/content/blog/{slug}.md
TARGET LANGUAGE: {language from fleet.config.yaml}
SITE: {domain from fleet.config.yaml}
BRAND: {brand_name from fleet.config.yaml}

CONTENT BRIEF (cite this data — never fabricate):
{content_brief_object as JSON}

FROZEN DATA REFERENCES (read these directly for additional context):
- {absolute path to keywords_*.json}
- {absolute path to keyword_gap_*.json}
- {absolute path to topic_briefs_*.json}
- {absolute path to paa_questions_*.json}

RULES:
- 1,500–2,000 words body
- Frontmatter must include `status: draft` (never `published`)
- Hero image: use placeholder `/images/blog/{slug}-hero.webp` and flag in your final output that a hero image needs to be uploaded
- Include at least 3 internal links from internal_link_candidates
- Answer 3–5 PAA questions verbatim in self-contained 50–80 word paragraphs
- Output ONLY the complete Markdown file content. No commentary, no JSON wrapper.

Write the blog now.
```

### 8. Save the file

Write the agent's output to `sites/{cc-lower}/src/content/blog/{slug}.md`.

Validate the frontmatter parses + has `status: draft`. If status isn't draft, force-correct it before saving (the agent is reliable but this is a critical safety check — drafts must not auto-publish).

### 9. Print summary

```
✓ Blog draft created

  File:           sites/nl/src/content/blog/iptv-eredivisie-2026.md
  Primary kw:     iptv eredivisie 2026
  Volume:         720/mo (NL)
  KD:             32
  Opportunity:    979.2
  Status:         draft   ← NOT live until you publish via Decap

  Word count:     ~1,820 words
  Internal links: /pricing/, /iptv-nederland/, /installatie/
  PAA answered:   3 questions (verbatim)

  Hero image needed: place at sites/nl/public/images/blog/iptv-eredivisie-2026-hero.webp

Next steps:
  1. Review the draft locally: pnpm --filter site-nl dev → http://localhost:4321/blog/iptv-eredivisie-2026
     (drafts visible in dev, hidden in prod)
  2. Or review in Decap CMS: https://iptvhelder.nl/admin/#/collections/blog/entries/iptv-eredivisie-2026
  3. Edit / refine
  4. Set status: published in Decap → Cloudflare rebuilds → live in ~2 min

Don't forget: upload the hero image, or replace the placeholder path.
```

### 10. Do NOT commit

Leave the file uncommitted on disk. The user reviews it next. They commit (or Decap commits when they publish).

If they want to commit the draft manually for backup, that's fine — drafts don't deploy to prod thanks to the Astro filter from Phase 7.

## Hard rules

- **Never set `status: published`** — that's a human decision via CMS
- **Never fabricate keyword metrics** — every volume/KD/PAA question must come from the frozen JSON files
- **Never skip the covered-set inventory** — duplicate-topic blogs hurt rankings
- **Never call Semrush MCP** — this command is entirely cache-fed
- **Never commit + push** — leave the draft for the user to review
- **Always pick a real internal-link target** — never invent paths the site doesn't have
