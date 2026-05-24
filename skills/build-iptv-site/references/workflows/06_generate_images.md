# Workflow: Image Generation (Nanobana)

**Goal:** Generate all site images — hero, device mockups, OG, blog headers — save to `public/images/`, update component references, ensure every image has target-language alt text.

---

## Required Inputs
- Brand color palette (primary, secondary, accent)
- Design personality (bold / warm / sleek / energetic)
- `target_country` (for cultural cues)
- Content files (to read alt text expectations)

---

## Image Manifest

| # | Purpose | Path | Resolution | Format |
|---|---|---|---|---|
| 1 | Homepage hero | `public/images/hero.webp` | 2560×1440 | WebP |
| 2 | OG default | `public/images/og-default.webp` | 1200×630 | WebP |
| 3 | Pricing hero | `public/images/pricing-hero.webp` | 1920×1080 | WebP |
| 4 | Free trial hero | `public/images/trial-hero.webp` | 1920×1080 | WebP |
| 5 | Channels hero | `public/images/channels-hero.webp` | 1920×1080 | WebP |
| 6 | About hero | `public/images/about-hero.webp` | 1920×1080 | WebP |
| 7 | Firestick device | `public/images/devices/firestick.webp` | 1200×800 | WebP |
| 8 | Android device | `public/images/devices/android.webp` | 1200×800 | WebP |
| 9 | Android TV | `public/images/devices/android-tv.webp` | 1200×800 | WebP |
| 10 | iOS/iPhone | `public/images/devices/ios.webp` | 1200×800 | WebP |
| 11 | Smart TV | `public/images/devices/smart-tv.webp` | 1200×800 | WebP |
| 12 | MAG box | `public/images/devices/mag.webp` | 1200×800 | WebP |
| 13 | Formuler | `public/images/devices/formuler.webp` | 1200×800 | WebP |
| 14 | Payment badges strip | `public/images/payment-methods.webp` | 1200×200 | WebP |
| 15+ | Blog headers (one per post) | `public/images/blog/{slug}.webp` | 1600×900 | WebP |

---

## Nanobana Prompt Patterns

### Hero (homepage)
```
Modern cinematic hero image of a premium home entertainment setup: a large 4K TV
mounted on a minimalist wall in a softly-lit contemporary living room, showing a
clean sports or cinema interface on screen (no logos, no recognizable content,
no text overlays). Color palette: {primary_hex}, {secondary_hex}, {accent_hex}.
Lighting: {design_personality_lighting}. Shot wide, shallow depth of field,
photorealistic, no watermarks.
```

`design_personality_lighting`:
- **Bold:** "dramatic contrast with rim lighting"
- **Warm:** "golden hour ambient warmth"
- **Sleek:** "soft diffused neutral daylight"
- **Energetic:** "vibrant colorful gradient lighting"

### Device mockups
```
Professional product photography of a {device_name} on a clean {primary_hex} tinted
surface, 3/4 angle, screen showing a generic streaming interface (no brand names,
no text), soft studio lighting, photorealistic, no watermarks, no people.
```

For country-specific context, append: `Background accent hints at {country_name}
without any flags, logos, or text.`

### OG image
```
Flat branded banner 1200x630 for social sharing. Background: subtle gradient
from {primary_hex} to {secondary_hex}, abstract modern shapes suggesting
streaming/TV (no literal screen), no text overlays (text will be added in code),
premium minimalist style.
```

### Blog post header
Read the blog post's primary_keyword and title, then:
```
Editorial illustration header for an article about {topic}. Modern flat
illustration style, {primary_hex} dominant, clean composition, no text, no logos,
no recognizable brands or people.
```

---

## Procedure

1. Load palette + personality from brand inputs.
2. For each image in the manifest, call Nanobana via `tools/nanobana_generate.py`:
   ```
   python tools/nanobana_generate.py \
     --prompt "{prompt}" \
     --width {w} --height {h} \
     --output {path} \
     --format webp
   ```
3. Validate each file:
   - Exists
   - Is valid WebP
   - Dimensions match manifest
   - File size < 300 KB for hero, < 150 KB for others (re-compress if over)
4. Update component references — replace any placeholder `/images/...` paths in `.astro` files with the actual generated paths.
5. Populate `alt` text from content files. Alt text must:
   - Be in `target_language`
   - Describe the image concretely (not "image of ...")
   - Include the primary keyword where natural, never forced
   - Be 60–125 characters

---

## Banned Image Content
- No real broadcaster logos (Netflix, ESPN, Sky, etc.) — DMCA risk
- No recognizable copyrighted content on TV screens
- No people with identifiable faces (privacy + rights issues)
- No country flags (too generic, dates the site)
- No text baked into the image — all text lives in DOM

---

## Learned Constraints
- Nanobana occasionally generates fake logos on TV screens even when told not to. Always visually review the hero + device images before continuing. Regenerate if any logo appears.
- WebP compression: use `cwebp -q 82` for heroes, `-q 78` for others. Higher quality hero is worth the bytes (it's LCP).
- Smart TV prompts tend to generate Samsung-looking bezels. Explicitly request generic bezel or add "unbranded TV" to the prompt.

---

## Output Handoff
Pass the populated `public/images/` directory and updated source files to `07_seo_audit.md`.
