# Canonical Pricing Tiers

The IPTV Helder build uses a **6-plan structure** as the default — 3 duration tiers × 2 pricing classes. This works across all European IPTV markets. Adjust prices per market, but keep the structure.

## 6-plan canonical structure

Source of truth lives at `src/data/pricing.ts` in the built Astro project (not templated in this skill — regenerate per brand).

| Plan | Duration | Screens | IPTV Helder (EUR) | Per-month equivalent |
|---|---|---|---|---|
| Starter 1M | 1 month | 1 | €15.99 | €15.99 |
| Popular 6M | 6 months | 1 | €34.99 | €5.83 |
| Best Value 12M | 12 months | 1 | €59.99 | €5.00 |
| Family 2-screen | 12 months | 2 | €89.99 | €7.50 |
| Family 3-screen | 12 months | 3 | €119.99 | €10.00 |
| Family 4-screen | 12 months | 4 | €149.99 | €12.50 |

**Featured plan:** `Best Value 12M` (single screen) — carries the `featured: true` flag in `pricing.ts`, rendered with a "Most Popular" badge and the `shadow-glow` card shadow.

## Per-market pricing grid (reference)

Adjust floor/median/ceiling from `gap_analysis.md` step 02. The floor should be **just below** the market median to convert on price-sensitive searches without looking like a scam; the ceiling (4-screen) should match or slightly undercut premium competitors.

| Country | 1M floor | 12M sweet spot | 4-screen ceiling | Currency format |
|---|---|---|---|---|
| NL | €12–16 | €55–65 | €140–160 | `€12,99` |
| DE | €12–16 | €55–65 | €140–160 | `12,99 €` |
| FR | €12–16 | €55–65 | €140–160 | `12,99 €` |
| ES | €10–14 | €45–55 | €120–140 | `12,99 €` |
| IT | €10–14 | €45–55 | €120–140 | `12,99 €` |
| UK | £10–14 | £45–55 | £120–140 | `£12.99` |
| US | $10–15 | $50–60 | $130–150 | `$12.99` |
| PT | €8–12 | €40–50 | €110–130 | `12,99 €` |
| PL | zł 40–60 | zł 200–250 | zł 500–600 | `49,99 zł` |

These are **starting guesses** — always override with competitor gap analysis for the specific market.

## Plan interface (TypeScript)

```ts
// src/data/pricing.ts
export interface Plan {
  id: string;
  name: string;              // Translated per language
  duration_months: number;
  screens: number;
  price: number;             // Number only, formatting happens at render
  currency: 'EUR' | 'GBP' | 'USD' | 'CHF' | 'PLN';
  per_month: number;         // Computed for display
  features: string[];        // Translated, 5–8 bullets
  featured?: boolean;        // At most ONE per array
  footnote?: string;         // Optional fine print
  checkout_url: string;      // Stripe / WHMCS / crypto gateway
}
```

## Feature list per plan (canonical 5 bullets)

Every plan shows the same 5 features with a ✓/✗ to highlight the upsell:

1. **Channel count** — e.g. "20 000+ chaînes live"
2. **VOD library** — e.g. "80 000+ films & séries"
3. **4K/HDR support** — "4K UHD sur les chaînes compatibles"
4. **Device count** — "1 appareil" / "2 appareils" / etc.
5. **Support** — "Support 24/7 via WhatsApp"

Plans above "Starter 1M" add:
6. **Savings badge** — "Économisez X%" vs the 1-month price
7. **Family feature** (2+ screens) — "Regardez en famille sur plusieurs TV"

## Schema.org for pricing

Each plan gets:

```json
{
  "@type": "Product",
  "name": "{plan.name}",
  "description": "{plan features joined}",
  "offers": {
    "@type": "Offer",
    "price": "{plan.price}",
    "priceCurrency": "{plan.currency}",
    "availability": "https://schema.org/InStock",
    "url": "{canonical pricing page + anchor}"
  }
}
```

Injected via `schema_types: ["Product", "BreadcrumbList"]` in the pricing page frontmatter. The `PricingCards.astro` component emits the JSON-LD inline.

## Payment methods per market

Pulled from `PaymentMethodsStrip.astro`. Defaults per locale:

| Market | Required methods |
|---|---|
| NL | iDEAL, Bancontact, SEPA, Visa, Mastercard, Crypto |
| DE | SEPA, Sofort, Giropay, Visa, Mastercard, Crypto |
| FR | SEPA, Carte Bancaire, Visa, Mastercard, PayPal, Crypto |
| UK | Visa, Mastercard, Apple Pay, Google Pay, Crypto |
| ES | SEPA, Visa, Mastercard, Bizum, Crypto |
| IT | SEPA, Visa, Mastercard, Crypto |
| US | Visa, Mastercard, Amex, PayPal, Apple Pay, Crypto |

**Crypto is always included** — IPTV buyers consistently prefer it for privacy. Use Coinbase Commerce or BTCPay Server as the gateway.
