# Banned Phrases + DMCA-Safe Framing

Enforced by `tools/content_linter.py`. Any content file containing a banned phrase gets rejected and re-written. Rules exist for two reasons: **legal exposure** (DMCA / broadcaster complaints) and **search quality signals** (Google deranks sites with copyright-infringing framing and generic filler).

## Banned: generic filler (quality reason)

Claude will produce these on first-pass ~10–20% of the time even with strict instructions. Reject and re-prompt.

- "best iptv service"
- "enjoy your favorite content"
- "take your entertainment to the next level"
- "immersive viewing experience"
- "in this fast-paced world"
- "in today's digital age"
- "revolutionize the way you watch"
- "unlock endless entertainment"
- "cutting-edge technology"
- "seamless streaming"
- Any sentence that could appear on 10 other IPTV sites unchanged

**Rule of thumb:** if a paragraph could be deleted without losing brand specificity, delete it.

## Banned: DMCA red flags (legal reason)

Never claim broadcaster licensing or ownership. These phrases invite takedown notices and reveal to Google that the site is framing itself as infringing:

- "licensed by [any broadcaster]"
- "official Netflix / Disney+ / HBO / Amazon Prime / Apple TV+"
- "watch [copyrighted show name] for free"
- "free Premier League / NFL / Champions League"
- "all channels included without subscription"
- "pirate iptv" / "free iptv" (even as a "what we're NOT" framing — avoid the word)
- "unlock [region-locked service]"
- Channel logo lockups in design (Sky, BeIN, DAZN, ESPN, Canal+ etc.)

## Banned: black-hat framing (English IPTV copy drift)

English IPTV copy in particular tends to drift toward these — actively steer away:

- "unlock everything"
- "no restrictions"
- "bypass geoblocks"
- "jailbreak your firestick"
- "no contracts, no questions"
- "100% anonymous"

## Approved: descriptive neutral framing

Use these patterns instead:

| Instead of | Use |
|---|---|
| "official Netflix" | "access to popular streaming libraries" |
| "licensed by ESPN" | "live sports channels" |
| "watch Premier League free" | "coverage of major football leagues" |
| "all channels" | "20,000+ channels" (only if cited in `verified_claims.json`) |
| "unlimited streaming" | "no bandwidth caps" |
| "jailbreak firestick" | "install on Amazon Firestick in 5 minutes" |

## Claim citation rule

**Every numeric claim** must cite a source in `verified_claims.json` (produced by step 02 competitor scan). This includes:
- Channel counts ("20,000+ channels")
- VOD library size ("80,000+ movies and series")
- Uptime ("99.9% uptime")
- Device count ("8 supported devices")
- Server locations ("servers in 12 countries")
- Response time ("24/7 support, avg 2 min reply")
- Prices (always from brand inputs, not competitor scan)

If it's not in `verified_claims.json`, **do not write it as a number**. Use soft framing ("thousands of channels") or pull a fresh scrape.

## Language purity rule

100% target-language body copy. Enforced by `tools/lang_detect.py` (wraps `lingua-language-detector`) with a >99% confidence threshold. Exceptions:
- Brand name (even if English)
- Device/app proper nouns (Firestick, Android TV, AppleTV — these don't translate)
- Currency codes (EUR, USD) in ISO contexts

**Common failure:** English brand taglines slipped into French copy. "Premium IPTV experience" in a French site will fail linting. Translate or rewrite.

## Currency formatting per locale

| Locale | Format | Decimal separator |
|---|---|---|
| US / UK / IE | `$9.99` / `£9.99` (symbol before) | `.` |
| FR / BE-fr / LU / CH-fr | `9,99 €` (symbol after, space before) | `,` |
| DE / AT / NL / BE-nl | `9,99 €` (symbol after, space before) | `,` |
| ES / IT / PT | `9,99 €` (symbol after, space before) | `,` |
| CH-de | `CHF 9.99` | `.` |

Never mix conventions on the same page. `content_linter.py` checks this with regex.

## Sports-season language

If the site launches mid-season, don't timestamp the copy ("as the 2025 Premier League season kicks off..."). Use evergreen framing ("catch every Premier League matchday live"). The same copy needs to work for the next 18 months without edits.
