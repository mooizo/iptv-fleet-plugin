---
name: iptv-brand-logo-prompt
description: Generate a ready-to-paste ChatGPT prompt that produces a clean SVG logo mark for a new IPTV/streaming country site. Use this skill whenever the user mentions designing a logo, mark, favicon, or brand identity for any IPTV site, country IPTV expansion (Norway, Germany, France, UK, Denmark, Italy, Spain, Netherlands, Belgium, Portugal, Ireland, Finland, etc.), or sister-brand of tvlumen.nl / vikingstream.tv. Trigger on phrases like "logo for [country] IPTV", "design a mark for [brand]", "make a logo prompt", "brand identity for new IPTV market", "what should the [country] IPTV logo look like", or any request that mentions both a streaming/IPTV brand and a visual identity element (mark, favicon, OG card, app icon). Sister skill to `build-iptv-site` — that skill builds the website, this skill provides the brand mark for it.
---

# IPTV Brand Logo Prompt

Codifies the playbook the user used to build the **VikingStream** mark — the single approach that actually worked across multiple tools tested (Recraft, Stitch, hand-SVG, ChatGPT/GPT Image 2). Output: a paste-ready ChatGPT prompt that produces a clean SVG mark on the first attempt 80%+ of the time, plus a refinement prompt for the second pass.

## When to use this skill

**Triggers:**
- "Logo for [country] IPTV site"
- "Design a mark for [brand]"
- "Make a logo prompt for my new [country] IPTV brand"
- "Brand identity for [new market]"
- Any mention of mark / favicon / OG card / app icon in the context of an IPTV expansion brand

**Do NOT use this skill for:**
- General logo design unrelated to IPTV (use a general design skill instead)
- Full UI design (use `build-iptv-site` for site construction)
- Logo *implementation* in code — once the SVG exists, the user wires it via inline components per the `build-iptv-site` pattern

## The playbook (what works, what doesn't)

The user tested four approaches building VikingStream. **Encode this knowledge — do not relitigate it.**

| Tool | Verdict | Why |
|---|---|---|
| **ChatGPT (GPT Image 2)** | ✅ **Use this** | Cleanest single-stroke SVG output, honors style references, follows anti-references, accepts "output as SVG" instructions |
| Recraft V4 / V4 Vector | ❌ Skip | Produces busy double-line marks that fail at favicon size; burns credits |
| Google Stitch | ❌ Wrong tool | For full UI layouts, not single marks |
| Hand-drafted SVG by Claude | ⚠️ Fallback only | Workable if the user has zero AI-image budget left, but lacks aesthetic exploration |

**Always recommend ChatGPT (GPT Image 2 / Sora) as the generator.** The skill's job is to produce the prompt for that tool, not to drive image generation directly.

## Critical lessons baked in

These came out of the VikingStream build. Honor all of them in every prompt you generate:

1. **Always request SVG explicitly** — phrase: "Output as an SVG file with clean vector paths, single-color, transparent background, no raster embeds." Without this, ChatGPT defaults to PNG.
2. **Require 32×32 favicon viability** — include "must work at 32×32 favicon size." Marks with too many interior lines fail here.
3. **Single line weight, asymmetric, generous negative space** — three phrases that consistently push outputs toward modern minimalism instead of generic clip-art.
4. **Aggressive anti-references per country** — listing what NOT to draw is more important than what to draw. Tourist clichés (helmets, axes, baguettes, beer steins) are the failure mode. Always include 8+ anti-references.
5. **Three layered readings** — the strongest marks fuse a brand letter + a streaming/motion cue + an abstracted cultural cue. Make this explicit in the prompt.
6. **First-pass + refinement** — the first generation is usually 80% there. A targeted 3-variation refinement pass is what closes the last 20%. Always provide both prompts.
7. **Style references are positive, anti-references are negative** — Linear, Vercel, Klarna, Acne Studios in the positive list; tourist-shop kitsch and far-right symbology in the negative list.

## Information to gather (or infer from context)

Before producing the prompt, you need these inputs. If the user's message already contains them, don't re-ask — extract and confirm. If anything is missing, ask **all missing items in a single AskUserQuestion turn** (don't drip-feed questions).

| Input | Default if not specified | Notes |
|---|---|---|
| **Brand name** | (required, must ask) | e.g. "VikingStream", "BaltStream", "GallStream" |
| **Target country** | (required, must ask) | Drives cultural cue + anti-references |
| **Letter from brand name to evoke** | First letter of brand name | e.g. V for VikingStream, T for tvlumen |
| **Brand accent color** | `#E8B547` (VikingStream gold) | Keep consistent across the user's portfolio if they want a family look |
| **Background color** | `#0B1620` (fjord navy) | Same default — but if they want the new brand to feel distinct, suggest a related-but-different navy |
| **Streaming motion cue** | Play arrow (default) | Alternatives: wave, flag, signal lines, pennant, chevron |
| **Cultural symbol/motif hint** | Use country defaults table below | Always abstract, never literal |

## Country cultural cue reference table

Use these as defaults when the user hasn't specified a cultural cue. **Always present them as "abstracted, never literal" — the goal is evocation, not depiction.**

| Country | Cultural cue (abstracted) | Anti-references (do NOT draw) |
|---|---|---|
| **Sweden** | Younger Futhark rune / Ringerike-style geometric stroke | horned helmet, axe, beard, dragon prow, blackletter, valknut/black-sun (far-right risk) |
| **Norway** | Stave-church angular geometry / abstracted longship prow | horned helmet, axe, beard, troll, fjord postcard cliché |
| **Denmark** | Dannebrog cross hint / single offset stroke | mermaid statue, Lego, hygge candle, literal Dannebrog flag |
| **Finland** | Sampo wheel geometry / Kalevala knot abstracted | sauna, reindeer, Moomin, Santa, Nokia nostalgia |
| **Germany** | Gothic angular geometry / abstracted eagle silhouette as single line | beer stein, lederhosen, Oktoberfest, swastika-adjacent symbology (avoid entirely), Brandenburg gate literal |
| **France** | Fleur-de-lis abstracted to single line / Bauhaus French-curve | beret, baguette, Eiffel tower, accordion, croissant |
| **UK** | Crown geometry abstracted / single-line lion silhouette / Union flag stroke | bowler hat, Big Ben, telephone box, bulldog, double-decker bus |
| **Netherlands** | Delft tile pattern abstracted / windmill blade as single chevron | wooden clog, tulip, literal windmill, cannabis leaf, orange football kit |
| **Spain** | Sol y sombra geometry / Mudejar arch single line / Iberian sun rays | bull, flamenco dancer, sangria, paella, sombrero (Mexican, not Spanish anyway) |
| **Italy** | Roman arch single curve / Etruscan geometry / Tricolore vertical stroke | Colosseum literal, pizza slice, pasta, Vespa, Mafia clichés |
| **Belgium** | Heraldic chevron / abstracted Atomium geometry | waffle, Tintin, beer, chocolate, French-fry cone |
| **Portugal** | Azulejo tile geometry / Manueline spiral abstracted single line | port wine bottle, fado guitar, rooster of Barcelos literal, sardine |
| **Ireland** | Celtic knot reduced to single continuous line / Ogham stroke | shamrock, leprechaun, Guinness, harp literal, green-orange-white tricolor obvious |
| **Iceland** | Bindrune abstracted / glacier crevice single stroke | troll, puffin, geyser, Viking horn (same as Norse) |
| **Estonia/Latvia/Lithuania** | Baltic sun symbol abstracted / single-line linden leaf | folk costume, amber jewelry, USSR-era nostalgia |
| **Poland** | Husaria wing single-line / Wawel dragon abstracted to chevron | accordion, kielbasa, Soviet bloc cliché, literal eagle |
| **Czechia** | Bohemian crystal geometric refraction lines | beer, Kafka, Soviet bloc, Prague astronomical clock literal |
| **Greece** | Meander/Greek key reduced to single asymmetric stroke | Parthenon literal, olive, ouzo, Spartan helmet, gyro |
| **Turkey** | Tugra-style calligraphic stroke / Iznik tile geometry abstracted | crescent obvious, kebab, hookah, fez, Hagia Sophia literal |

If the country is not in this table, ask the user what cultural element they want hinted at, or suggest *no* cultural cue and rely on the brand letter + motion cue alone (which often produces a stronger result anyway).

## Output format — what to give the user

When invoked, produce a single response with these exact sections (in this order):

### 1. Recommended tool

State: "Generate this in **ChatGPT** with **GPT Image 2** model (also called Sora image gen in some UIs). Do NOT use Recraft — its v3/v4 produce busy double-line marks that fail at favicon size. Do NOT use Stitch — that's for full UI layouts, not marks."

### 2. First-pass prompt (paste-ready)

Format as a single fenced code block, ~120 words, ready to copy-paste. Use this template:

```
Minimal modern logo mark for "[BRAND_NAME]", a premium [COUNTRY]-targeted streaming/IPTV brand. A single continuous monolinear geometric symbol that fuses three readings: (1) the letter [LETTER] from the brand name, (2) a streaming/forward-motion cue ([MOTION_CUE]), and (3) an abstracted [CULTURAL_CUE] reference. Premium, calm, modern — in the spirit of Linear, Vercel, Klarna, and Acne Studios. Single line weight, asymmetric, generous negative space, geometric precision. Warm accent color [ACCENT_HEX] on dark navy [BG_HEX] background. Suitable for a favicon at 32×32 and an app icon. No text, no wordmark, [COUNTRY_ANTI_REFERENCES_LIST], no blackletter, no ornamental decoration, no shading, no gradient, no 3D depth. Just the geometric mark. Output as an SVG file with clean vector paths, single-color, transparent background, no raster embeds.
```

Substitute the bracketed placeholders with the gathered inputs. The `[COUNTRY_ANTI_REFERENCES_LIST]` should be the comma-separated anti-references from the table above (e.g. for France: "no berets, no baguettes, no Eiffel tower, no accordions, no croissants").

### 3. Refinement prompt (paste-ready)

Format as a single fenced code block. Use this template:

```
Same mark, three tight refinements:
1. Same composition but make [SPECIFIC_FIX_BASED_ON_FIRST_PASS — leave as placeholder for user].
2. Same composition but with [ALTERNATE_MOTION_CUE_ROTATION_OR_ANGLE_VARIATION].
3. Same composition but with slightly heavier stroke weight throughout — want to see it with ~50% more weight for better presence at small sizes.

Keep everything else identical: [ACCENT_HEX] on [BG_HEX], vector, single line weight, no shading, no decoration. Output as SVG.
```

Tell the user to fill in step 1 with the specific thing they want fixed from the first generation (most common: closing an open letterform, repositioning a misaligned element, simplifying interior detail).

### 4. Verification checklist

After they receive the SVG, the user should check:

- [ ] **Filetype is `.svg`**, not `.png` (re-prompt if PNG)
- [ ] **File size < 2 KB** (anything larger usually means embedded raster or bloat)
- [ ] **Opening the file in a text editor shows clean `<path>` elements** — no `<image href="data:image/...">` (that's an embedded raster, reject)
- [ ] **Single fill or stroke color** matching the requested accent hex
- [ ] **Transparent background** (no `<rect fill>` covering the canvas unless explicitly requested)
- [ ] **viewBox is roughly square** (`0 0 1024 1024` or similar) — long rectangular viewBoxes mean the mark isn't centered
- [ ] **Renders cleanly at 32×32** — preview at favicon size before approving

### 5. Next steps after the SVG is approved

Once the user has the final SVG, list the downstream work the `build-iptv-site` skill (or manual implementation) will handle:
- Inline the SVG into a `Mark.astro` component using `currentColor` for the stroke
- Generate favicon kit (32px, 192px, 512px PNG via `sharp`) + apple-touch-icon (180×180)
- Generate OG card (1200×630 PNG with mark + wordmark + tagline)
- Wire into Header, Footer, Layout, web manifest
- Reference: see the VikingStream implementation in `/Users/boullamjaouad/iptv for sweden ads/public/logos/` and `src/components/ui/Mark.astro`

## Working examples (for reference)

### Example: VikingStream (Sweden) — the production prompt

```
Minimal modern logo mark for "VikingStream", a premium Sweden-targeted streaming/IPTV brand. A single continuous monolinear geometric symbol that fuses three readings: (1) the letter V from the brand name, (2) a streaming/forward-motion cue (small flag/pennant at the top of the right leg), and (3) an abstracted Younger Futhark / Ringerike rune-stroke reference. Premium, calm, modern — in the spirit of Linear, Vercel, Klarna, and Acne Studios. Single line weight, asymmetric, generous negative space, geometric precision. Warm gold #E8B547 on dark navy #0B1620 background. Suitable for a favicon at 32×32 and an app icon. No text, no wordmark, no horned helmets, no axes, no beards, no dragon prows, no shields, no blackletter, no ornamental decoration, no shading, no gradient, no 3D depth, no valknut, no black-sun symbology. Just the geometric mark. Output as an SVG file with clean vector paths, single-color, transparent background, no raster embeds.
```

Resulted in a mark that read as V + rune-flag + forward-pennant in 3 iterations.

### Example sketch: tvlumen (Netherlands)

For the Dutch sister site, the equivalent prompt would substitute:
- Brand name → `tvlumen`
- Letter → `T`
- Motion cue → `subtle play arrow integrated into the T crossbar`
- Cultural cue → `abstracted Delft tile pattern or windmill blade as a single chevron`
- Anti-references → `no clogs, no tulips, no literal windmills, no cannabis leaves, no orange football kits`

## Reference materials

- **VikingStream PRD pattern** (full brand identity reasoning): `~/.claude/plans/help-me-create-a-parsed-metcalfe.md`
- **VikingStream project memory**: `~/.claude/projects/-Users-boullamjaouad-domain-name-ideas/memory/project_vikingstream.md`
- **tvlumen project memory**: `~/.claude/projects/-Users-boullamjaouad-domain-name-ideas/memory/project_tvlumen.md`
- **Anti-references philosophy reference**: `references/anti-references.md`
- **Output examples library**: `references/examples.md`

## Don't do this

- **Don't generate the SVG yourself** unless the user explicitly says they're out of ChatGPT credits and want a hand-drafted fallback. The whole point of this skill is to leverage GPT Image 2's aesthetic exploration.
- **Don't recommend Midjourney/DALL-E/Flux as alternatives** — they're raster-first and require a vectorization pass that loses fidelity. GPT Image 2 wins on direct SVG output.
- **Don't list more than ~12 anti-references** in the prompt — past that, ChatGPT starts ignoring the list. Cap at the 6–10 worst cultural clichés.
- **Don't ask the user to choose between cultural cues if you have a strong default** from the table. Recommend one, then ask if they want to override.
- **Don't burn time on synthetic evaluation** — the output is subjective and short-form. The skill succeeds when the user gets one usable prompt and ships a logo from it. Real-world usage is the test.
