# Workflow: Deploy to Cloudflare Pages

**Goal:** Ship the audited site to production on Cloudflare Pages, wire DNS, submit sitemap to Google Search Console.

---

## Required Inputs
- Audit report from workflow 07 showing `overall: PASS`
- Cloudflare API token (from `.env`: `CLOUDFLARE_API_TOKEN`)
- Cloudflare account ID (from `.env`: `CLOUDFLARE_ACCOUNT_ID`)
- Target `domain`
- Google Search Console verification method preference (DNS TXT or HTML file)

---

## Step 1 — Production build

```bash
npm run build
```

Confirm zero errors, zero warnings. If warnings, loop back to audit.

---

## Step 2 — Deploy via Wrangler

```bash
npx wrangler pages deploy ./dist \
  --project-name={project_slug} \
  --branch=main \
  --commit-dirty=true
```

Capture the returned preview URL. Verify it loads. Smoke-test:
- Homepage loads in target language
- Pricing page shows correct currency
- One device install page loads
- A blog post loads
- 404 page loads branded

---

## Step 3 — Custom domain

Via Cloudflare API:
1. Add custom domain to Pages project: `POST /accounts/{account_id}/pages/projects/{project}/domains`
2. If domain is already on Cloudflare → auto DNS. Else → instruct user to add CNAME.
3. Wait for SSL provisioning (usually < 2 min).
4. Verify HTTPS works and auto-redirects from HTTP.

---

## Step 4 — Security headers

Create `public/_headers` before deploying (if not already in project):
```
/*
  Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: geolocation=(), camera=(), microphone=()
```

Redeploy if headers file was added after first deploy.

---

## Step 5 — Google Search Console

1. Add property for `https://{domain}`
2. Verify via chosen method (DNS TXT record via Cloudflare API is fastest)
3. Submit sitemap: `https://{domain}/sitemap-index.xml`
4. Request indexing for: homepage, pricing, each device page
5. Check for crawl errors after 24h

---

## Step 6 — Bing Webmaster Tools (recommended)

Import verification from GSC. Submit same sitemap. Bing often indexes IPTV sites faster than Google.

---

## Step 7 — Post-launch monitoring setup

Save to `.tmp/{country}_{lang}/launch_report.md`:
- Deployed URL + preview URL
- Cloudflare project ID
- GSC property + verification date
- Bing WMT property + verification date
- List of pages indexed (run `tools/check_indexed.py` weekly)
- PageSpeed baseline scores at launch
- Schema validation pass/fail per URL

---

## Step 8 — Handoff to user

Present final report:

```
Launch Complete — {brand_name}

Production URL:  https://{domain}
Preview URL:     https://{hash}.pages.dev
Target market:   {country_name} ({target_language})

Pages live:      {count}
Blog posts:      {count}

Lighthouse (launch baseline):
  Performance:   {score}
  SEO:           {score}
  Accessibility: {score}
  Best Practices:{score}

Schema:          All {n} pages validate on Rich Results Test
Sitemap:         Submitted to GSC + Bing WMT

Env vars to set in Cloudflare dashboard:
  - {any required runtime keys}

Next steps (manual):
  1. Verify contact form submission works end-to-end
  2. Add real testimonials as they come in
  3. Monitor GSC for first indexing within 48–72h
  4. Start backlink outreach (blog guest posts, niche directories)
```

---

## Learned Constraints
- Cloudflare Pages free plan has a 20 MB file limit per asset. Heroes that creep above 500 KB are fine — the limit is per-file, not per-bundle.
- `wrangler pages deploy` silently skips files > 25 MiB. Check output for warnings.
- GSC property verification via DNS TXT takes 5–30 min. If verifying via HTML file, make sure it's in `public/` BEFORE the final build.
- Some IPTV providers use cloaked domains behind Cloudflare because registrars occasionally deplatform them. If deplatforming is a concern, the user should maintain a backup registrar + domain ready to CNAME.
- **GSC property format:** Search Console properties registered via domain-level verification use `sc-domain:{domain}` format, NOT `https://{domain}/`. The `check_indexed.py` tool auto-detects the correct format by probing both. If you add a URL-prefix property instead, `https://{domain}/` is used. The first run after launch will auto-detect and log which format works.
- **`site:` search fallback is unreliable.** The `--force-fallback` mode (Google `site:` queries) produces false positives — it matches URL fragments in the results page HTML rather than confirming actual indexation. Always prefer the GSC URL Inspection API (requires `GSC_SERVICE_ACCOUNT_JSON` in `.env`). Never trust `site:` results as ground truth.
- **New-domain indexing timeline.** For a brand-new domain, expect: homepage indexed in 1–3 days, remaining pages move from "URL is unknown to Google" → "Discovered - currently not indexed" → "Submitted and indexed" over 1–4 weeks. Request indexing via Search Console URL Inspection for high-priority pages (homepage, pricing, free-trial, top device pages) to accelerate. The "Discovered - not indexed" state is normal and does NOT indicate a quality problem — Google is just building trust in the new domain.
- **GSC service account setup for `check_indexed.py`:** Requires a GCP service account (not an API key). Set `GSC_SERVICE_ACCOUNT_JSON=/path/to/file.json` in `.env`. The service account email must be added as "Full User" on the Search Console property. API keys (`AIzaSy...`) do NOT work for URL Inspection — they're only valid for PageSpeed Insights and similar public APIs.
