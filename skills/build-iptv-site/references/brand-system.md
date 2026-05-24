# IPTV Brand System

The brand tokens live in `assets/tailwind.config.iptv.mjs` — copy verbatim into a new project and only change the three palette hex values for a new brand. Everything else (typography scale, radius scale, shadows, spacing) stays identical across all IPTV builds.

## Palette structure

Three brand colors, plus a blue-tinted neutral scale:

```js
brand: {
  primary:   '#204289', // deep navy — H1/H2, dark bands, primary text
  secondary: '#0070CC', // vibrant blue — CTAs, highlights (WCAG AA darkened)
  accent:    '#1D5AD0', // mid blue — links, icon accents (WCAG AA)
}
```

**Backward-compatible tokens** (kept so existing components don't need renaming):
- `ink` scale (50→950) — blue-tinted grays; `ink.900` = brand.primary
- `flame` scale — re-pointed from warm orange to brand.secondary blue; `flame.500` is the primary CTA fill
- `coral` scale — secondary blue; `coral.500` is the accent
- `paper` = `#FFFFFF`

### Re-skinning for a new brand

Phase A of SKILL.md collects the user's palette, font, and design personality. Apply them as follows:

1. Read `brand_inputs.json` from `.tmp/{country}_{lang}/`
2. Swap the 3 hex values in `colors.brand.*`
3. Regenerate the `ink` / `flame` / `coral` scales around the new hues (keep the same lightness curves — shift hue, preserve value steps)
4. **Verify WCAG AA contrast** for secondary on white (4.5:1 minimum for body text, 3:1 for large text). If it fails, darken the color and notify the user with a before/after comparison.
5. Update `theme-color` in `BaseLayout.astro` to match the new `brand.primary`
6. Update shadow rgba values to use the new primary hue instead of `rgba(32,66,137,...)`

The IPTV Helder source palette was `#204289 / #0089F7 / #286CF5` — `#0089F7` was **darkened to `#0070CC`** to pass AA on white. Do this check for every new brand.

### Design personality → token overrides

The `design_personality` from `brand_inputs.json` maps to token adjustments:

| Personality | borderRadius | boxShadow | Animation | Notes |
|---|---|---|---|---|
| **Professional** (default) | DEFAULT=5px, max 10px | flat blue-tinted | fade-in + slide-up | Current defaults — no changes needed |
| **Bold** | DEFAULT=8px, max 12px | stronger card shadow, thicker glow ring | same + scale-in for CTAs | Increase shadow opacity 1.5× |
| **Sleek** | DEFAULT=10px, max 16px | glass-card blur + glow | fade-in + blur-in | Add dark-mode sections (`bg-ink-950`), glass card with `backdrop-blur-lg` |
| **Energetic** | DEFAULT=8px, max 14px | bright glow using accent color | slide-up + bounce for stats | Replace section.spacing with `5rem` (tighter), add gradient-mesh backgrounds |
| **Warm** | DEFAULT=12px, max 20px | soft warm-tinted shadows | gentle fade-in only | Override `ink` scale with warm grays (`hsl(30, 5%, ...)`), increase body line-height to 1.7 |

Apply overrides by editing `tailwind.config.mjs` after copying the template. Never change the IPTV-specific components — personality only affects tokens + layout wrappers.

## Typography

**Default font:** Plus Jakarta Sans for everything (display + body). Weights 400, 500, 600, 700, 800 are self-hosted as woff2 in `public/fonts/` and preloaded in `BaseLayout.astro`.

### User-provided font override

If the user picks a different font in Phase A:

1. **Google Fonts** — download woff2 files for weights 400, 500, 600, 700 using `google-webfonts-helper` or direct download. Place in `public/fonts/{font-name}/`.
2. **Custom woff2** — user provides files directly. Place in `public/fonts/`.
3. Update `tailwind.config.mjs`:
   ```js
   fontFamily: {
     display: ['"UserFont"', 'system-ui', '-apple-system', 'sans-serif'],
     sans:    ['"UserFont"', 'system-ui', '-apple-system', 'sans-serif'],
   }
   ```
4. Update `BaseLayout.astro` `<link rel="preload">` tags to point to the new font files.
5. Add `@font-face` declarations in `global.css` for each weight.

### Tested font alternatives for IPTV

These are pre-validated for readability, weight range, and IPTV niche tone:

| Font | Tone | Weights available | Notes |
|---|---|---|---|
| **Plus Jakarta Sans** (default) | Clean, modern, premium | 200–800 | Excellent x-height, very readable at 16px |
| **Inter** | Neutral, highly legible | 100–900 | Best for information-dense pricing tables |
| **DM Sans** | Geometric, tech-forward | 400, 500, 700 | Good for "sleek" personality |
| **Outfit** | Rounded, friendly | 100–900 | Pairs well with "warm" personality |
| **Space Grotesk** | Technical, modern | 300–700 | Strong for "bold" personality |
| **Manrope** | Clean, slightly rounded | 200–800 | Versatile mid-ground option |

### Display scale (unchanged regardless of font)

Fluid, clamp-based:
- `display-xl` — clamp(2.5rem, 5.5vw, 3.5rem) — ~56px at lg — H1
- `display-lg` — clamp(2rem, 4.5vw, 3rem) — ~48px at lg — H2
- `display-md` — clamp(1.5rem, 3vw, 2.25rem) — ~36px — H3

All display sizes use `fontWeight: 700`, `letterSpacing: -0.02em` (xl/lg) or `-0.015em` (md), line-height 1.1–1.2.

Body: 16px / 1.6 line-height / weight 400.

## Radius (flat design)

Intentionally flat — everything ≤10px:

```js
borderRadius: {
  sm: '3px', DEFAULT: '5px', md: '5px', lg: '5px',
  xl: '6px', '2xl': '8px', '3xl': '10px', full: '9999px'
}
```

Never use `rounded-full` except for pill badges and avatars. IPTV sites that use heavy rounding read as low-trust.

## Shadows

Professional, flat, blue-tinted (no warm glow):

```js
boxShadow: {
  soft:  '0 1px 2px rgba(32,66,137,.04), 0 1px 3px rgba(32,66,137,.06)',
  card:  '0 4px 12px -2px rgba(32,66,137,.08), 0 2px 6px -2px rgba(32,66,137,.05)',
  glow:  '0 0 0 1px rgba(0,137,247,.15), 0 8px 24px -6px rgba(0,137,247,.25)',
}
```

The glow shadow is the only place the pure-bright secondary color appears — reserve for featured CTAs and the featured pricing card.

## Spacing

One custom token: `spacing.section = 6.5rem`. Use `py-section` for all full-width sections on desktop; mobile collapses naturally because Tailwind's padding scale handles it.

Content max-width: `max-w-content` = `72rem` (1152px). Never stretch body copy wider.

## Animation

Two keyframes only: `fade-in` (0.5s ease-out) and `slide-up` (0.6s ease-out, 16px y-offset). Apply sparingly — the site should feel calm, not busy.

## Files that depend on this

- `assets/tailwind.config.iptv.mjs` — the source of truth
- `assets/BaseLayout.astro` — preloads the fonts + sets `theme-color` = `#204289`
- `assets/components/*.astro` — all use these tokens

When you re-skin, check `BaseLayout.astro:theme-color` and the favicon `.svg` primary color too.
