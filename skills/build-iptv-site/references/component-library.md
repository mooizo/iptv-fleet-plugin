# Component Library Inventory

23 components from the IPTV Helder build. The 6 IPTV-specific ones are templated in `assets/components/`. The 17 generic ones should be regenerated per brand in step 05 (they get brand-specific styling anyway).

## IPTV-specific (copy verbatim from `assets/components/`)

| Component | Purpose | Data source |
|---|---|---|
| **ChannelGrid.astro** | Grid of channel categories (Sports, News, Films, Series, Kids, International) with icons, descriptions, channel counts | Hardcoded category list + counts from `verified_claims.json` |
| **SportsLeaguesGrid.astro** | League/competition tiles (Premier League, La Liga, NFL, UFC, F1, etc.) — country-specific subset | Country-adjusted from keyword research (step 01) |
| **DeviceGrid.astro** | 8-tile device support matrix (Smart TV, Firestick, Android TV, Formuler, iPhone, Android, MAG, AppleTV) with inline SVG icons and links to `/devices/{slug}/` | Hardcoded 8 devices — **don't deviate per brand** |
| **PricingCards.astro** | 6-plan card layout with featured badge, per-month equivalent, feature list, CTA, footnote | `src/data/pricing.ts` — single source of truth |
| **ComparisonTable.astro** | Brand vs. competitor matrix (desktop 3-col grid, mobile stacked cards) across ~7 criteria: trial, uptime, iDEAL/SEPA, price transparency, 4K, device support, support channels | `gap_analysis.md` from step 02 |
| **PaymentMethodsStrip.astro** | Horizontal icon strip of accepted payment methods (iDEAL, SEPA, Visa, MC, Stripe, crypto, PayPal) — country-specific subset | Brand input + country defaults |

### Which devices to show in DeviceGrid

The 8 slots are fixed: Smart TV, Firestick, Android TV, Formuler, iPhone/iOS, Android, MAG, Apple TV. Don't add/remove — the grid layout depends on exactly 8. If the brand only supports 6, ghost the unsupported 2 with a "Coming soon" overlay rather than deleting.

## Generic (regenerate per brand in step 05)

These are listed so the tech-builder agent knows the full component set, but the source files are **not** templated in this skill — each brand needs its own styling:

| Component | Purpose |
|---|---|
| Header.astro | Top nav + logo + mobile menu toggle + primary CTA |
| Footer.astro | Multi-column footer + legal links + device links + brand |
| Hero.astro | Full-width hero (headline, subhead, CTA, trust strip, optional video) |
| FAQ.astro | Accordion, 2-column layout (heading + details) |
| CTA.astro | Generic centered call-to-action block |
| Testimonial.astro | Single testimonial card (avatar, quote, source) |
| USPList.astro | 3-item unique-selling-points strip with icons |
| HowItWorks.astro | 3–4 step process section |
| BrandLogoStrip.astro | Small partner/brand logos |
| LogoStrip.astro | Generic logos strip |
| BlogGrid.astro | Blog post card grid (image, date, category, excerpt, read time) |
| ContentBlock.astro | Generic markdown content wrapper |
| ContentShowcase.astro | Styled content section with accent rule |
| InterfaceShowcase.astro | Alternating image/text layout for feature walkthrough |
| ProsePage.astro | Long-form markdown article wrapper (legal pages, blog) |
| StatsBar.astro | Key metrics bar (subscribers, uptime, support response time) |
| PlansPreview.astro | Compact 3-card preview for homepage |

## Component data conventions

- **Pricing data** lives in `src/data/pricing.ts` as a typed `Plan[]` — single source of truth. All pricing components import from here.
- **Icons** are inline SVG (no icon libraries). The DeviceGrid SVGs in `assets/components/DeviceGrid.astro` are copy-paste ready.
- **Images** referenced as `/images/{slug}.webp` (served from `public/images/`). Always WebP, always lazy-loaded unless above-fold.

## Tailwind class patterns

- Section padding: `py-section` (6.5rem) on desktop
- Content width: `max-w-content` (72rem) with `mx-auto px-6`
- Card shadow: `shadow-card hover:shadow-glow transition`
- Primary CTA: `bg-flame-500 hover:bg-flame-600 text-white font-semibold rounded px-6 py-3`
- Section heading: `text-display-lg text-brand-primary font-display`

## Accessibility conventions from the source build

- Every interactive element has a `:focus-visible` ring (`focus-visible:ring-2 focus-visible:ring-coral-500`)
- Icons inside buttons get `aria-hidden="true"` + visible text label
- Mobile menu uses `aria-expanded` + `aria-controls`
- Images always have `alt` — never empty unless purely decorative (in which case `alt=""`)
