---
description: Find the best SEO domain for a new IPTV market — keyword-phrase (EMD) candidates built from the market's real keywords, checked for live availability + price, ranked with the SEO-vs-takedown trade-off. Usage:/iptv-domain-search {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. FR, ES, IT, UK, PT)"
---

# /iptv-domain-search {country}

Find a registrable, SEO-strong domain for the `{country}` IPTV site. Defaults to **competitor-style keyword-phrase (EMD) domains** built from the market's own validated keywords, always surfaces 1–2 brandable fallbacks, checks **live availability (RDAP) + price (Firecrawl)**, and returns a ranked recommendation with the SEO-vs-takedown-risk trade-off stated plainly.

**Touches Semrush API: NO.** Reads cached keyword JSON. Uses Firecrawl (pricing) + optionally Perplexity (naming strategy). **DataForSEO: optional**, only if the market has no cached keywords yet.

> **Why this exists / the governing principle** (see `skills/build-iptv-site/references/seo-pillars.md` Technical pillar → "Domain resilience"): the strongest *keyword* `.com`s are almost always already taken (that's why early competitors rank); EMD gives only a *modest* CTR/relevance benefit in 2026 (Google neutralized the old bonus) — but a keyword-phrase domain still matches what winning competitors do (`smart-iptv-pro`, `meiniptvanbieter` = literal keyword phrases). The real trade is **keyword relevance/CTR vs takedown + ad-account-flag risk**. NEVER recommend a country-code TLD (`.de`, `.nl`, …) for IPTV — those registries suspend fast. Prefer `.com`/`.tv`/`.store`; a lax offshore TLD (`.to`/`.cc`) only if survival > trust.

## What to do

### 1. Validate
- Argument required: ISO-3166 alpha-2 (e.g. `FR`). Normalize uppercase for paths.
- Resolve market language + country name (e.g. FR → French, France) from `fleet.config.yaml` or the standard map.

### 2. Load the market's validated keywords (the EMD seed material)
- Read the latest `keywords_*.json` from `~/.claude/skills/seo-data-store/data/{COUNTRY}/`.
- If missing: tell the user to run `/iptv-seo-ingest-{cc}` first, OR (optional) pull a quick keyword set via DataForSEO `dataforseo_labs_google_keyword_overview` for the market's seed terms (confirm cost first — DataForSEO is gated/paid per memory).
- Take the **top ~8 highest-volume commercial/head terms** + the geo term (e.g. `smart iptv`, `iptv kaufen`, `iptv anbieter`, `iptv {country}`, `bestes iptv`, `iptv test`). These are the EMD building blocks.

### 3. Generate candidate domains (keyword-phrase first)
Build the candidate set from the keyword seeds, in three tiers:

**Tier A — keyword-phrase EMD (default, competitor-style):** combine each head keyword with the country/modifier and common patterns:
- `{kw}.com`, `{kw-hyphenated}.com`, `{kw}{geo}.com`, `{kw}-{geo}.com`, `{kw}24.com`, `bestes-{kw}.com`
- e.g. for FR: `iptv-france.com`, `smart-iptv-france.com`, `iptv-abonnement.com`, `meilleur-iptv.com`, `acheter-iptv.com`
- Localize the modifiers to the market language (DE: kaufen/anbieter/deutschland; FR: acheter/abonnement/france; ES: comprar/proveedor/españa; IT: comprare/abbonamento/italia).

**Tier B — `iptv`-suffix brandable** (keyword signal + slightly more brandable): `{prefix}iptv.com` where prefix is a short market-relevant word.

**Tier C — neutral brandable fallback (always include 1–2):** a name WITHOUT "iptv" for takedown insurance (e.g. a market-language "smart TV / cable-free / stream-choice" phrase). This is the 301 fallback, not the primary.

Generate ~20–25 candidates across tiers.

### 4. Check availability (RDAP — free, deterministic)
For each candidate, query the TLD's RDAP endpoint; **404 = AVAILABLE**, 200 = TAKEN. Use:
- `.com` → `https://rdap.verisign.com/com/v1/domain/{d}`
- `.net` → `https://rdap.verisign.com/net/v1/domain/{d}`
- `.store` → `https://rdap.nic.store/domain/{d}` ; `.stream` → `https://rdap.nic.stream/domain/{d}`
- `.media` → `https://rdap.donuts.co/rdap/domain/{d}`
- For `.tv` and TLDs whose RDAP rejects the query (400/403), **skip RDAP and verify via Firecrawl in step 5** (the registrar results page shows availability directly).

Run this as a short Python/bash loop (see the pattern in the iptv-fleet repo session history). Keep only AVAILABLE candidates.

### 5. Get live price + confirm availability (Firecrawl)
For each AVAILABLE candidate (and any `.tv`/odd-TLD ones RDAP couldn't check), scrape the registrar results page with `mcp__firecrawl__firecrawl_scrape`, `formats:["json"]`, `waitFor: 6000`:
- URL: `https://www.namecheap.com/domains/registration/results/?domain={candidate}`
- JSON schema: `{ domain, available (bool), price (string, first-year) }` — prompt: "Extract ONLY the exact searched domain result: availability + first-year price. Ignore suggestions."
- **Flag premium pricing** (anything > ~$50/yr is an aftermarket/premium domain — mark and de-prioritize).
- Prices may render in the scraper's geo currency (₹/€/$) — normalize to a rough USD note.

### 6. Rank + recommend
Score each available, non-premium candidate on:
- **Keyword strength** — does it contain the #1 head keyword? the geo? (higher = better SEO/CTR)
- **Trust/resilience** — `.com`/`.tv` > `.store`/`.stream` > cheap-spammy (`.xyz`/`.online`) > offshore; no ccTLD ever.
- **Brandability** — readable, not stuffed/hyphen-spam (`iptv-cheap-best-247.com` = bad).
- **Price.**

Output a **ranked markdown table**: `Domain | Avail | Price | Keyword strength | Trust/resilience | Note`, then:
- **One primary recommendation** with 2–3 sentences of why (lead with the highest-volume keyword the market's top competitor's domain also uses).
- **The honest trade-off caveat:** a keyword-heavy domain maximizes SEO/CTR + competitor-parity but is the most takedown- and ad-account-flag-prone. State it every time.
- **A neutral `.com` fallback recommendation** (~$7) to register alongside + 301 to if the keyword domain is ever actioned — cheap insurance.
- **Registrar note:** Namecheap or Porkbun with WHOIS privacy (NOT a country registrar); DNS on Cloudflare.

### 7. Save the report
Write to `~/.claude/skills/seo-data-store/data/{COUNTRY}/domain_search_{YYYY-MM-DD}.md` (the table + recommendation) so the decision is on record next to the market's SEO data.

## Output handoff
Once the user registers the chosen domain, the rebrand + attach flow is: update `fleet.config.yaml` `domain` + the site's `src/seo.config.ts` (siteUrl/brand) + content brand strings → attach as a custom domain to the `iptv-{cc}` Cloudflare Pages project → submit to GSC. (That step is `/iptv-deploy` + a manual Cloudflare custom-domain attach.)

## Cost
- RDAP: free. Firecrawl: ~1 credit per candidate priced (≈15–25/run). Perplexity (optional naming strategy): ~$0.01. **Semrush: 0. DataForSEO: 0** unless the market has no cached keywords.

## Notes / gotchas
- The best plain-keyword `.com`s (`iptv-kaufen.com`, `iptvdeutschland.com`, etc.) are almost always TAKEN — expect to land on a keyword+geo phrase (`smart-iptv-{country}.com`) or an `{prefix}iptv.com`. That's normal; it's why early competitors rank.
- Namecheap geolocates the scraper, so prices may appear in ₹/€ — normalize.
- `.tv` is genuinely on-brand for streaming and low-suspension, but ~3–5× the price of `.com` and gives no SEO bonus — only pick it for the brand signal.
- Always register the neutral fallback too; "iptv" in the domain is the risk the user is knowingly accepting.
