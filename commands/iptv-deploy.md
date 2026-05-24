---
description: Build and deploy a country site to Cloudflare Pages. Usage:/iptv-deploy {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. DE, NL)"
---

# /iptv-deploy {country}

Build the country's Astro site, deploy `dist/` to Cloudflare Pages, submit the sitemap to Google Search Console, and update `fleet.config.yaml`.

## What to do

### 1. Validate
- Argument is required, ISO-3166 alpha-2.
- Confirm `sites/{cc}/` exists. If not, error: "Run `/iptv-new {cc}` first."
- Confirm `fleet.config.yaml` has an entry for `{cc}` with `status` in `built | live`. If `planned` or `building`, error: "Site isn't ready to deploy — run `/iptv-new {cc}` to finish the pipeline first."

### 2. Build
```bash
pnpm --filter site-{cc} build
```

Fail loudly if build fails. Print the last 20 lines of build output for context.

### 3. Pre-deploy audit (quick gates)
- Confirm `sites/{cc}/dist/index.html` exists
- Confirm `sites/{cc}/dist/sitemap-index.xml` exists
- Confirm at least one page has `<title>` and `<meta name="description">` set
- If any fails, abort and tell the user to re-run `/iptv-new {cc}` to regenerate

### 4. Deploy
```bash
cd sites/{cc}
wrangler pages deploy dist --project-name=iptv-{cc} --commit-dirty=true
```

Capture the deploy URL from the wrangler output.

### 5. Verify deploy
- `curl -fsI https://{domain}/` returns 200
- If not, warn the user but don't fail (DNS may not be propagated yet)

### 6. Submit sitemap to GSC
Use the `mcp__gsc__submit_sitemap` tool:
- `site_url`: `https://{domain}/`
- `sitemap_url`: `https://{domain}/sitemap-index.xml`

If GSC submission fails (site not verified yet, etc.), warn but don't fail the deploy.

### 7. Update fleet.config.yaml
- `status: live`
- `last_deployed: <UTC ISO timestamp>`
- Commit the change:
  ```bash
  git add fleet.config.yaml
  git commit -m "fleet({cc}): deployed to {domain}"
  git push
  ```

### 8. Run the post-deploy hook
The `post-deploy-gsc.sh` hook in this plugin handles GSC sitemap submission if the inline call above failed.

### 9. Report

Tell the user:
```
✓ Site live: https://{domain}
  Cloudflare URL: {wrangler deploy URL}
  Sitemap submitted to GSC
  fleet.config.yaml updated and committed

Next: /iptv-status to see the fleet
```

## Hard rules

- **NEVER deploy a site with status `planned` or `building`** — those aren't ready.
- **NEVER skip the pre-deploy audit** — better to catch missing schema before going live than after Google indexes broken pages.
- **ALWAYS commit the `fleet.config.yaml` change** so the source of truth stays in sync with reality.
