# Workflow: Write Content (Step 04) — 2026-aware, IPTV-specific

**Goal:** Per-page copy for every page in the country site — all `src/content/pages/*.md`, plus seed `src/content/blog/*.md` drafts for the app/device-guide cluster — produced by the [`iptv-seo-writer`](../../../../agents/iptv-seo-writer.md) agent against the frozen Semrush data, 2026-aware, DMCA-safe, and ready for `iptv-tech-builder` to wire into the Astro project at step 05.

This workflow is the **driver**; the [`iptv-seo-writer` agent](../../../../agents/iptv-seo-writer.md) is the **executor**. Everything below echoes the agent's contract at workflow level — full prose recipes (H1 formulas, atomic-answer examples, brand-vs-keyword tables, comparison-table schemas, CTA copy bank) live in the agent file. Don't restate them here; point to them.

This step lives in [Pillar 2 (Content) + Pillar 3 (On-Page)](../seo-pillars.md) of the SEO framework. It is the step where six of the eight DE-audit HARD FAILs were earned — making it the highest-leverage step in the pipeline to get right.

---

## Required Inputs

| Input | Path | Use |
|---|---|---|
| Frozen Semrush keyword universe | `~/.claude/skills/seo-data-store/data/{CC}/keywords_YYYY-MM-DD.json` | Primary + secondary KW selection with real `volume` + `kd`. Never invent. |
| Frozen Semrush keyword-gap data | `~/.claude/skills/seo-data-store/data/{CC}/keyword_gap_YYYY-MM-DD.json` | High `opportunity_score` topics → H2 wording, blog backlog seeds |
| Frozen Semrush PAA wording | `~/.claude/skills/seo-data-store/data/{CC}/paa_questions_YYYY-MM-DD.json` | Verbatim question wording for FAQ + atomic-answer H2/H3 |
| Frozen Semrush topic briefs | `~/.claude/skills/seo-data-store/data/{CC}/topic_briefs_YYYY-MM-DD.json` | Section outlines: `subtopics[]`, `headlines[]`, `entities[]` |
| Page map | `.tmp/{country}_{lang}/page_map.json` (from step 03) | Page roles, slugs, primary KW assignments |
| Brand config | `sites/{cc}/brand.yaml` | Brand name, tone, plans/prices, payment methods, currency, stats |
| Banned-phrase contract | [`../banned-phrases-dmca.md`](../banned-phrases-dmca.md) | Banned filler + DMCA red flags + approved neutral framing |
| Frontmatter schema | [`../content-frontmatter-schema.md`](../content-frontmatter-schema.md) | The exact YAML shape every `*.md` file must satisfy |
| Competitor playbook (if step 02 ran) | `.tmp/{country}_{lang}/ranking_playbook.md` | "Exploit list" — out-cover competitor weaknesses |
| Competitor ranking factors (if step 02 ran) | `.tmp/{country}_{lang}/ranking_factors.json` | `weaknesses[]` → where to write deeper than the SERP norm |

**Hard precondition.** If the country's frozen Semrush files don't exist at `~/.claude/skills/seo-data-store/data/{CC}/`, **stop**. Run `/iptv-seo-ingest-{cc}` first. The writer agent refuses to fabricate volumes, KD, or PAA wording.

---

## Procedure (how to invoke the writer agent)

1. **Verify inputs.** Confirm the frozen Semrush files exist for `{CC}` and the page map declares a `primary_keyword` for every page.
2. **Spawn the agent.** Invoke [`iptv-seo-writer`](../../../../agents/iptv-seo-writer.md) per page (or per batch of pages where the agent can hold the full page-map in context). Pass:
   - `country_code`, `target_language`, `brand` block from `brand.yaml`
   - The page slug + role + declared `primary_keyword` + declared `secondary_keywords[]`
   - The frozen Semrush file paths (by exact dated path, not `latest.json`)
   - The competitor playbook + ranking_factors paths if present
   - The full `page_map` so the agent can run the anti-cannibalization check
3. **Receive structured output.** The agent returns the Deliverable Format described in `agents/iptv-seo-writer.md` (§"Deliverable Format"). It includes the five mandatory verification blocks listed in §"Quality Gate" below.
4. **Gate the output.** If any verification block self-reports a fail, send it back to the writer with the specific failure — do **not** hand off to `iptv-tech-builder`.
5. **Materialize files.** Convert each accepted deliverable to a markdown file under `.tmp/{country}_{lang}/content/` mirroring the page-map paths.

---

## Mandatory Copy Rules — Universal (apply to every page)

The writer must satisfy all of these. They mirror the [`iptv-seo-auditor`](../../../../agents/iptv-seo-auditor.md) HARD FAIL gates.

### Primary keyword placement
- **H1 contains the primary KW unbroken** (no brand inserted inside the compound, no brand-only H1). The compound must be a substring of the H1 text after entity decode.
- Primary KW appears in `meta_title`.
- Primary KW appears in `meta_description`, **within the first 30 characters**.
- Primary KW appears in the **first sentence of the intro paragraph**.
- Primary KW appears in **≥3 distinct body sections** (intro + ≥2 H2 sections).
- Primary KW appears in **≥1 H2**.

### Brand placement rule
The exact target compound must be UNBROKEN. Brand goes **before** or **after** the keyword, **never inside it**. ("IPTV Klar Abonnement" splits `iptv abonnement` — wrong. "IPTV Abonnement bei IPTV Klar" keeps it whole — right.) See the agent's full table for every page role.

### Secondary keyword placement
- Each declared secondary KW **must appear in body text ≥1 time on standard pages, ≥2 times on money pages**. This is the writer-side mirror of auditor HF-1.
- Best landing spots, in order of effectiveness: FAQ-question wording → H3 sub-heading → body sentence in the matching section → comparison-table row label → on-page internal-link anchor.
- If a secondary KW doesn't fit naturally, **restructure** the section or **drop it** from `secondary_keywords[]`. Do not declare a KW the body doesn't carry.

### Keyword density ceiling
**No single KW exceeds 4% of body text.** Semantic matching is the 2026 norm; stuffing now actively hurts. Primary KW target density 1.5–2.5%; each secondary 0.3–1%.

### Atomic answers (the biggest 2026 on-page win)
- **≥2 question-style H2/H3 (text ending with `?`)** on every money page and every app/device guide.
- Each followed immediately by a **40–80-word self-contained declarative paragraph**. Paragraph first; an optional bullet list may follow.
- Question wording mirrors a real PAA query — pull verbatim from `paa_questions_*.json` where topically related. ([Semrush — Google AI Mode](https://www.semrush.com/blog/google-ai-mode/))

### Front-loading (40–45% of AI citations come from the first 30%)
The first **200 rendered words** of every money page must contain: (1) the primary KW unbroken ≥1, (2) a geo cue ("Deutschland" / "in Nederland" / "UK"), (3) a concrete value prop (refund window, trial, price, support language), (4) either an atomic answer or a strong USP line. **Forbidden openings:** brand storytelling, "Willkommen bei …", origin story, feature list without context. ([digitalapplied — zero-click 2026](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026))

### DMCA safety
- No phrase from [`banned-phrases-dmca.md`](../banned-phrases-dmca.md).
- No broadcaster-licensing implication ("official Netflix", "licensed by DAZN").
- No "free premium channels" framing.
- No black-hat verbs ("unlock", "jailbreak", "bypass geoblock").
- Use the approved neutral framing column from the banned-phrases reference.

### Language & locale purity
- 100% target-language body copy (brand name + device proper nouns excepted).
- Correct currency symbol + decimal convention (`9,99 €` on DE/NL/FR/ES/IT/AT/BE; `£9.99` on UK; `$9.99` on US/CA).
- Correct geo references — never wrong-country place names.
- Dates + thousand separators in the target locale's format.

### Character counts (HARD)
- `meta_title`: **50–60 characters** after HTML-entity decode.
- `meta_description`: **140–160 characters** after HTML-entity decode.
- Both counts reported in the writer's `CHARACTER_COUNTS` verification block.

### Structure
- **Exactly one `<h1>` per page.** (The Astro layout renders the frontmatter `h1`; markdown body must NOT start with `# Title`.)
- Title tag ≈ H1 (same primary KW, can re-word for length).
- Stats delivered as `{ number, label }` pairs the tech-builder can render at oversized scale — never invented; pulled from `brand.yaml.stats` or omitted.

---

## Page Role Specifics

For full prose recipes (H1 formulas with worked examples, meta formulas, required section ordering, schema declarations) see `agents/iptv-seo-writer.md` §"IPTV Page Roles & Content Recipes". The summary below is the workflow-level gate — the agent must hit every cell.

### Homepage (`src/content/pages/index.md` → rendered by `src/pages/index.astro`)
- **Primary KW**: high-volume geo or category seed (DE: `smart iptv` 12,100/mo; NL: `iptv` or `iptv nederland`).
- **H1**: `{Primary KW} in {Country}: {Trust hook}` — unbroken primary KW + geo cue in first 8 words.
- **Required sections (in order)**: front-loaded intro · "Warum/Waarom {Brand}" USP block (4–6 bullets, each one concrete number) · plans summary card (3 tiers from `brand.yaml`) · ≥2 atomic-answer blocks · FAQ (5–8 Q&As, ≥3 lifted verbatim from PAA) · CTA closer.
- **Secondary KWs**: 6–10 — every one in body, landed in USP bullets / plan-card subtitles / atomic-answer H2s / FAQ Q wording.
- **Schema**: `WebSite` (with SearchAction), `Organization`, `Product`, `FAQPage`, `BreadcrumbList`.
- **FAQ count target**: 5–8.

### Money pages — `iptv-{country}` / `iptv-anbieter` / `iptv-abo` / `iptv-kaufen` / `bestes-iptv-{country}` / `iptv-vergleich`
- **Primary KW**: the page's name-equivalent KW (e.g. `iptv-anbieter.md` → primary `iptv anbieter`).
- **H1**: `{Primary KW} {Geo}: {Differentiator}` — unbroken, brand outside the compound.
- **Required sections**: atomic intro · "what makes a good {provider/sub/purchase/best}" extractable block · comparison table (mandatory on `iptv-vergleich` + `bestes-iptv-*`; strongly recommended elsewhere) · pros/cons · ≥2 atomic-answer H2/H3 · FAQ (5–8) · CTA closer linking `/pricing/` + `/free-trial/`.
- **Secondary KWs**: 5–10 — **each ≥2 occurrences in body** (writer-side HF-1 enforcement).
- **Schema**: `Product` (for sub/pricing-framed money pages), `FAQPage`, `BreadcrumbList`.
- **FAQ count target**: 5–8.

### Pricing page (`pricing.md`)
- **Primary KW**: `iptv abonnement` / `iptv abonnement` (NL) / `iptv subscription` (UK).
- **H1**: `{Primary KW}: {Tier summary}` — never `{Brand} {Primary KW}` (HF-4).
- **Required sections**: atomic intro · pricing table (semantic `<thead>` + descriptive `<th>` — never "Option 1") · tier-by-tier detail · refund-guarantee block · payment-methods row · FAQ · CTA.
- **Schema**: `Product` with `offers[]` whose `price` values match the visible table exactly. The auditor cross-checks visible price ↔ JSON-LD `price` — drift is a HARD FAIL.
- **Plans/prices source**: `brand.yaml.plans` only — never invent.
- **Comparison table**: MANDATORY. Caption + ≥3 tier rows.
- **FAQ count target**: 3–5 (billing/cancellation/refund focus).

### Trust pages — `about.md` · `contact.md` · `iptv-legal-{country}.md`
- **About**: founder/origin story (200–300 words), **named operator**, credentials, mission, link to legal page. Required E-E-A-T source. Person schema source.
- **Contact**: working email (from `brand.yaml`), legal address if applicable, response-time promise. Optionally `ContactPage` schema.
- **Legal (`iptv-legal-{cc}.md`)**: DMCA-safe framing (we sell connectivity / server-time, not licensed broadcaster content), user-responsibility language, takedown contact. **Primary KW** `iptv legal {country}` / `is iptv legaal` — H1 must contain the primary compound; brand-only H1 forbidden.
- **Schema**: `AboutPage` + `Organization` + `BreadcrumbList` (about); `ContactPage` + `Organization` (contact); `WebPage` + `BreadcrumbList` (legal).

### Conversion — `free-trial.md`
- **Primary KW**: `iptv kostenlos testen` / `iptv gratis proberen` / `iptv free trial`.
- **H1**: `{Primary KW}: 24 Stunden, ohne Kreditkarte` (or locale equivalent).
- **Required sections**: short atomic intro · single conversion form prominent above fold · 3-bullet trust reassurance · FAQ (3 — what gets activated / what happens after 24h / does it auto-convert) · no comparison table.
- **Schema**: `Product` (the trial as a $0 offer) optional; `BreadcrumbList` required.

### Setup — `installation.md`
- **Primary KW**: `iptv einrichten` / `iptv installeren` / `iptv setup`.
- **Required sections**: atomic intro · prerequisites · named-device step blocks (Fire TV, Smart TV, Android Box, iOS — each a named `<ol>` step list with device-specific notes) · EPG setup · troubleshooting · legal note linking `/iptv-legal-{cc}/`.
- **Schema**: `HowTo` with named `step[]` entries — each step needs `name` + `text`. `BreadcrumbList` required.

### App / device guides (blog cluster) — `src/content/blog/{slug}.md`
The long-tail cluster competitors win on. Topics: TiviMate setup on Fire TV, IPTV Smarters on Apple TV, M3U playlist loading, EPG configuration, troubleshooting freezes, etc.
- **Primary KW**: app+device+action compound (`tivimate fire tv einrichten`, `iptv smarters apple tv setup`, `m3u playlist tivimate laden`).
- **H1**: `{App} {Action} {Device}: {Year} {Helper}` — **year in H1** (freshness signal).
- **Length**: ≥800 body words, or p75 of competitor norm if higher.
- **Required sections**: atomic intro (names device + version + test date) · requirements · numbered `<ol>` step block (HowTo source) · playlist/Xtream input step · EPG · troubleshooting (table or FAQ) · legal note · **E-E-A-T author block**.
- **Schema**: `HowTo` (not `Article`) + `BreadcrumbList`. If the blog layout can't emit `HowTo` yet, the writer flags it for tech-builder.
- **Internal links**: ≥3 — homepage with KW anchor, `/pricing/` with benefit anchor, the matching money page (`/iptv-anbieter/` etc.).
- **Mode override**: when invoked via `/iptv-blog-new`, the agent's "Blog Mode" rules supersede page-mode rules — 1,500–2,000 words, `status: draft`, frontmatter per `content-frontmatter-schema.md` blog block, no `published` flag, no `updated_date` on creation.

### Hub pages — `faq.md` · `blog/index.md`
- **FAQ hub** primary KW: `iptv faq` / `iptv vragen` / `iptv fragen`. H1 must include "FAQ" or the primary compound; brand-only H1 forbidden. **15–25 Q&As** lifted from PAA + cluster gaps. **Schema**: `FAQPage` with every Q/A appearing verbatim in visible HTML (auditor HARD FAIL otherwise — schema-content alignment).
- **Blog index**: short hub framing, no body keyword targeting.

---

## E-E-A-T Author Block

Every blog post + every app/device guide MUST include:

- **Named byline at the top**: `Von {Name}` / `Door {Name}` / `By {Name}`.
- **Author bio block at the end**: "Über den Autor" / "Over de auteur" — 2–3 sentences with credentials and a link to `/about/` or `/authors/{slug}/`.
- **First-hand testing language**: name the device (`Fire TV Stick 4K Max`), the version (`TiviMate 5.x`), the test date (`Im Mai 2026 getestet`), the outcome (`In unter 6 Minuten betriebsbereit`). If not actually tested, write `[TESTING TODO: confirm device {X}, version {Y}, date {Z}]` — never fake.
- **Person schema source**: the bio populates the `Person` node in JSON-LD, linked via the `Article`/`HowTo` `author` property. The writer delivers it as structured `author_block` data in the page deliverable.

Money pages don't require a per-page author block but benefit from a footer "Geschrieben vom Team {Brand}" + link to `/about/`. The `Person` schema for the named operator lives on `/about/` and is referenced site-wide.

E-E-A-T's "Experience" E is the YMYL-adjacent differentiator in 2026 — real device screenshots, named author, version numbers, "I tested X for N weeks". ([Search Engine Land — recognition not rankings](https://searchengineland.com/seo-goal-recognition-476756))

---

## Anti-Cannibalization Check

Before finalizing each page, the writer lists its declared `primary_keyword` + `secondary_keywords[]` and runs two checks:

1. **No two pages on the same site declare the same `primary_keyword`.** Verified by reading every existing `sites/{cc}/src/content/pages/*.md` frontmatter and the in-progress page-map. If a collision exists, change the angle and pick a sibling KW from `keyword_gap_*.json`.
2. **If a secondary KW on page A is the primary KW on page B**, that's tolerable IF the page angles differ (e.g. `iptv anbieter` as secondary on the homepage but primary on `iptv-anbieter.md`). The writer **flags it in the `ANTI_CANNIBALIZATION_CHECK` block** for operator review.

The DE site map (current owned primary KWs) is the canonical reference table in `agents/iptv-seo-writer.md` §"Anti-Cannibalization Check". Read it before drafting any new DE page.

---

## 2026 Critical Rules (the 6 writer-owned HARD FAILs)

These are the six DE-audit HARD FAILs the writer agent is directly accountable for. The workflow surfaces them here so any operator reviewing the deliverable can spot-check fast.

1. **HF-1 — Declared secondary KW absent from body.** Every KW listed in `secondary_keywords[]` must appear in body text ≥1 time (≥2 on money pages). If the writer can't land it naturally, drop it from the declared list — don't lie. ([Search Engine Land — recognition not rankings](https://searchengineland.com/seo-goal-recognition-476756))
2. **HF-2 — Primary KW under-placed.** Primary KW must appear in H1 unbroken, in `meta_title`, in `meta_description` first 30 chars, in the first sentence of the intro, in ≥3 body sections, in ≥1 H2.
3. **HF-3 — H1 missing the primary compound.** Pure-punch marketing headlines that miss the keyword (e.g. `Ein IPTV-Anbieter, der seine Karten offen legt` when primary is `iptv anbieter deutschland`) fail the auditor. The hero subheading carries punch; the H1 carries the keyword.
4. **HF-4 — Brand inserted INSIDE the keyword compound.** `IPTV Klar Abonnement` breaks `iptv abonnement`. Brand goes BEFORE or AFTER the keyword, never inside it. Brand-only H1s (`IPTV Klar — Wähle deinen Tarif`) waste the strongest ranking signal slot.
5. **Atomic-answer absence on money pages + app guides.** ~50–60% of queries return AI Overviews in 2026; the atomic-answer pattern (question-style H2/H3 + 40–80-word declarative paragraph immediately under) is the single biggest on-page upgrade for AI extraction. ≥2 per money page + per app guide is the floor. ([eseospace](https://eseospace.com/blog/how-ai-overviews-impact-seo-2026/), [Semrush](https://www.semrush.com/blog/google-ai-mode/))
6. **Cannibalization — two pages claiming the same primary KW.** Every page's `primary_keyword` is unique across the site map. Violations confuse Google's intent-routing and split internal-link equity.

Two structural anti-patterns also routinely produce auditor HARD FAILs and the writer must avoid them:

- **Front-load violation** — first 200 words open with brand storytelling instead of primary KW + geo + USP/atomic answer. 40–45% of AI citations come from the first 30% of a document. ([digitalapplied](https://www.digitalapplied.com/blog/zero-click-search-seo-strategy-guide-2026))
- **Schema-content drift** — FAQ Q/A in JSON-LD that isn't visible verbatim in the HTML; Product `offers[].price` that doesn't match the visible pricing table. The writer's deliverable is the source for both — they must agree.

---

## Quality Gate — Pre-handoff Self-Audit

The writer's deliverable for every page MUST include the five verification blocks below (full schema in `agents/iptv-seo-writer.md` §"Deliverable Format"). The workflow gates on these — if any block self-reports a fail, send back to the writer; do not hand off to `iptv-tech-builder`.

| Block | Pass condition | Failure routing |
|---|---|---|
| `KEYWORD_COVERAGE_VERIFICATION` | primary KW present in all 6 slots; every declared secondary has `body_occurrences ≥1` (≥2 on money pages) with a recorded `placement` | Return to writer with the missing slot(s) listed |
| `CHARACTER_COUNTS` | `meta_title` 50–60; `meta_description` 140–160 | Return to writer with the over/under count |
| `FRONT_LOAD_SAMPLE` | first 200 words pasted verbatim; `contains_primary_kw: yes`, `contains_geo_cue: yes`, `contains_atomic_answer_or_usp: yes`, `contains_brand_storytelling_first: no` | Return to writer to rewrite the intro |
| `ANTI_CANNIBALIZATION_CHECK` | `primary_kw_owned_elsewhere_on_site: no`; secondary collisions flagged for operator review | Operator decides: change the angle/KW or accept the documented overlap |
| `DMCA_SAFETY_CHECK` | `banned_phrases_present: no`; `broadcaster_licensing_implied: no`; `free_premium_channels_implied: no` | Return to writer — DMCA is non-negotiable, fleet survival depends on it |

In addition the writer must mentally run the full §"Pre-handoff Self-Audit" checklist from the agent file before returning. Eleven gates, including the six 2026 Critical Rules above plus atomic-answer count, comparison-table presence on best-of/vergleich/pricing, and locale purity.

---

## Output Handoff

Accepted writer output lands as one markdown file per page under `.tmp/{country}_{lang}/content/` mirroring the page-map slugs:

```
content/
  index.md
  iptv-{country}.md
  iptv-anbieter.md            (or iptv-provider / iptv-aanbieder per locale)
  iptv-abo.md                 (or iptv-abonnement)
  iptv-kaufen.md              (or iptv-kopen)
  bestes-iptv-{country}.md
  iptv-vergleich.md
  pricing.md
  free-trial.md
  installation.md
  about.md
  contact.md
  iptv-legal-{country}.md
  faq.md
  blog/
    tivimate-fire-tv-einrichten-2026.md
    iptv-smarters-apple-tv-setup-2026.md
    ...
```

Each file's frontmatter conforms to [`../content-frontmatter-schema.md`](../content-frontmatter-schema.md) (pages collection for `*.md` under `content/`, blog collection for `content/blog/*.md`). Pages collection emits `published`-ready content; blog drafts ship with `status: draft` so Decap CMS publishes on operator review.

Hand off the populated `.tmp/{country}_{lang}/content/` directory to [`05_build_astro.md`](./05_build_astro.md), where `iptv-tech-builder` wires it into the Astro project, emits JSON-LD that matches the visible content exactly, and verifies the build.
