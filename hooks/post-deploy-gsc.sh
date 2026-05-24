#!/usr/bin/env bash
# post-deploy-gsc.sh
# Runs after `wrangler pages deploy` succeeds for an iptv-fleet site.
# Submits the sitemap to Google Search Console via the GSC MCP tool.
#
# The /iptv-deploy command tries to submit the sitemap inline. This hook
# is the fallback if that inline call failed (e.g. MCP transiently unavailable).
#
# Activation:
#   - The plugin manifest declares this as a PostToolUse hook on wrangler deploy
#   - The hook reads $IPTV_DEPLOY_DOMAIN and $IPTV_DEPLOY_COUNTRY from env
#     (set by /iptv-deploy before calling wrangler)
#
# Usage (manual): ./post-deploy-gsc.sh {country-code} {domain}
#   e.g.   ./post-deploy-gsc.sh de iptvklar.de

set -euo pipefail

CC="${1:-${IPTV_DEPLOY_COUNTRY:-}}"
DOMAIN="${2:-${IPTV_DEPLOY_DOMAIN:-}}"

if [[ -z "$CC" || -z "$DOMAIN" ]]; then
  echo "post-deploy-gsc: missing country or domain. Skipping."
  exit 0
fi

SITE_URL="https://${DOMAIN}/"
SITEMAP_URL="${SITE_URL}sitemap-index.xml"

echo "post-deploy-gsc: submitting ${SITEMAP_URL} to GSC for ${SITE_URL}"

# The GSC MCP tool is invoked by Claude, not by this shell script.
# This script just writes a marker file that the next Claude session can pick up
# and act on (since shell hooks can't call MCP tools directly).
MARKER_DIR="${HOME}/.claude/skills/seo-data-store/data/${CC^^}"
mkdir -p "$MARKER_DIR"
cat > "${MARKER_DIR}/pending_gsc_submission.json" <<EOF
{
  "site_url": "${SITE_URL}",
  "sitemap_url": "${SITEMAP_URL}",
  "country": "${CC^^}",
  "queued_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "post-deploy-gsc: marker written to ${MARKER_DIR}/pending_gsc_submission.json"
echo "Next /iptv-status or /iptv-deploy call will pick this up and submit via MCP."
