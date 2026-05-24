# IPTV Page Architecture (Locked)

This is the 9-page structure that every IPTV site built with this skill must follow. It's not a suggestion — gap analysis across 20+ European IPTV markets showed this exact structure captures all commercial search intent. Deviating per-brand costs rankings.

## The URL map

```
/                         Homepage            — hero + USPs + plans preview + trial CTA
/pricing/                 Plans & pricing     — primary conversion page
/channels/                Channel lineup      — searchable/filterable, country-specific
/free-trial/              Trial signup        — high-intent landing page
/devices/                 Device hub          — index of supported devices
/devices/firestick/       Install guide       — Amazon Firestick
/devices/android/         Install guide       — Android phones/tablets
/devices/android-tv/      Install guide       — Android TV boxes
/devices/ios-iphone/      Install guide       — iOS / iPhone
/devices/smart-tv/        Install guide       — Samsung / LG
/devices/mag-box/         Install guide       — MAG boxes
/devices/formuler/        Install guide       — Formuler Z series
/faq/                     FAQ                 — FAQPage schema
/blog/                    Blog index          — topical authority
/blog/[slug]/             Blog post           — from keyword research
/contact/                 Contact + support   — email / WhatsApp / Telegram
/about/                   Trust page          — why choose us
/legal/terms/             Terms of service
/legal/privacy/           Privacy policy
/legal/refund/            Refund policy
```

## Page types (Zod enum in `content-config.ts`)

```ts
page_type: homepage | pricing | trial | channels | devices_index |
           device | installation | faq | about | contact | blog
```

## Required linking rules

- **Every device page** must link to `/pricing/` + `/free-trial/` **above the fold**
- **Homepage** must link to `/pricing/` + `/free-trial/` in the hero CTA
- **Pricing page** must link to each device guide in a "Works on" strip
- **Blog posts** must link to `/pricing/` once + one relevant device page once
- **FAQ** must link to the contact page for unresolved questions
- **Footer** must link to all legal pages + all device guides

## Schema.org types per page (minimum)

| Page | Required schema |
|---|---|
| `/` homepage | `WebSite` (SearchAction), `Organization`, `BreadcrumbList` |
| `/pricing/` | `Product` + `Offer` per plan, `BreadcrumbList` |
| `/devices/{device}/` | `HowTo`, `BreadcrumbList` |
| `/faq/` | `FAQPage` |
| `/blog/{slug}/` | `Article`, `BreadcrumbList` |
| `/contact/` | `ContactPage`, `Organization` |
| `/about/` | `AboutPage`, `Organization` |

The baseline `WebSite` + `Organization` is injected automatically by `BaseLayout.astro` on every page. Per-page schema is merged from `schema_types` frontmatter.

## Copy structure per page type

### Homepage
Hero → USPStrip (3 items) → Plans preview (3 cards) → DeviceGrid (8 tiles) → Testimonial → Blog preview (3 latest) → FAQ (5 questions) → Footer CTA

### Pricing
Plans table (6 plans canonical — see `pricing-tiers.md`) → Payment methods strip → Money-back note → 3-question billing FAQ → Schema: Product + Offer

### Device guide
Hero (device name + "install IPTV on X") → Prerequisites callout → 5–9 numbered install steps → Mid-page plans CTA → 3 troubleshooting items → Schema: HowTo

### Blog post
1200–2500 words, ≥3 H2s, internal link to /pricing/ + 1 device page, hero image with keyword-rich alt, author = `{brand_name} Editorial`, schema Article + BreadcrumbList

### FAQ
15–25 questions, 40–80 words each, 3 sections: "About the service" / "Setup & devices" / "Billing & support"

## Why this structure is locked

Analysis of top-ranking IPTV sites in NL, DE, FR, ES, IT, BE, UK, PT showed:
- **Homepage + pricing + device pages** capture 70% of commercial clicks
- **Device pages** individually rank for "IPTV {device}" long-tail queries (high intent, low KD)
- **FAQ + blog** pick up informational queries that convert ~30% lower but build topical authority
- **Trial page** separates trial-intent from plan-intent users — cleaner analytics and higher trial-to-paid conversion

Sites that try clever reorganizations (e.g. merging device pages into a single tabbed page, or skipping the trial page) consistently rank 5–10 positions lower on device queries.

## Multilingual reminder

One language per domain. Never emit `hreflang` alternates. For a country with multiple languages (BE, CH, LU, FI), pick one language and build one site. If the user needs multiple languages, build multiple sites on separate domains or subdomains — never combine.
