---
name: iptv-fleet-orchestrator
description: The conductor for the iptv-fleet plugin. Decides which sub-skill or agent to invoke when the user runs a /iptv-* slash command or makes a natural-language request like "build IPTV Germany", "deploy NL site", "refresh SEO data for France". Reads fleet.config.yaml and routes accordingly. Use proactively whenever the user mentions a country IPTV site, multi-country IPTV fleet management, or any /iptv-* command.
---

# IPTV Fleet Orchestrator

This is the **conductor skill** for the `iptv-fleet` plugin. It does not do work itself — it routes the user's request to the correct sub-skill, agent, or command.

## When this skill activates

Any of the following:
- User runs a `/iptv-*` slash command (`/iptv-new`, `/iptv-deploy`, `/iptv-status`, `/iptv-refresh-seo`)
- User says something like:
  - "build IPTV Germany"
  - "deploy the NL site"
  - "what's the status of the fleet?"
  - "refresh SEO for France"
  - "add a new country IPTV site for Spain"

## Routing decision tree

### 1. Detect intent
| User says / runs | Route to |
|---|---|
| `/iptv-status` or "show fleet" or "list IPTV sites" | Command `/iptv-status` |
| `/iptv-new {cc}` or "build IPTV {country}" or "new IPTV site" | Command `/iptv-new` |
| `/iptv-deploy {cc}` or "deploy {country} site" or "ship {country}" | Command `/iptv-deploy` |
| `/iptv-refresh-seo {cc}` or "refresh Semrush for {country}" | Command `/iptv-refresh-seo` |
| "design a logo for {country} IPTV" | Sub-skill `iptv-brand-logo-prompt` |
| Anything else IPTV-related | Sub-skill `build-iptv-site` (the encyclopedia of how to do anything in the pipeline) |

### 2. Extract country code

If the user says a country name, map to ISO alpha-2:
- "Germany" → DE
- "France" → FR
- "Spain" → ES
- "Italy" → IT
- "Netherlands" / "Holland" → NL
- "UK" / "United Kingdom" → UK
- "Portugal" → PT
- For multilingual countries (BE, CH), ask which language

If the user didn't specify a country, ask via `AskUserQuestion`.

### 3. Locate `fleet.config.yaml`

Try in order:
1. `./fleet.config.yaml` (current working dir)
2. `~/Code/iptv-fleet/fleet.config.yaml`
3. Search common locations: `~/Code/*/fleet.config.yaml`, `~/Desktop/*/fleet.config.yaml`

If still not found, tell the user: "I can't find the iptv-fleet monorepo. Clone it: `gh repo clone mooizo/iptv-fleet ~/Code/iptv-fleet`"

If found but cwd isn't the monorepo root, suggest: "cd into `~/Code/iptv-fleet` first — the commands assume that's the working directory."

## What this skill knows (cheat sheet)

### Source of truth
`iptv-fleet/fleet.config.yaml` — every country's brand + status

### Companion skills (in this plugin)
| Skill | Purpose |
|---|---|
| `build-iptv-site` | The 8-step pipeline encyclopedia. Read its workflows for any individual step. |
| `iptv-brand-logo-prompt` | Generate a ChatGPT prompt for an SVG brand logo |

### Companion skill (external, in its own repo)
| Skill | Purpose |
|---|---|
| `seo-data-store` | Pull + cache Semrush data per country. Lives at `~/.claude/skills/seo-data-store/`. Pushes to `github.com/mooizo/seo-data-store`. |

### Agents (in this plugin)
| Agent | When to spawn |
|---|---|
| `iptv-seo-writer` | Step 04 of the pipeline — writes all per-page markdown |
| `iptv-tech-builder` | Step 05 — scaffolds the Astro site for a new country |
| `iptv-seo-auditor` | Step 07 — audits the built site before deploy |

### Locked architecture (never change)
- 9 page types: home, pricing, channels, free-trial, devices (+ device subpages), faq, blog, about, contact, legal
- Single locale per domain — no hreflang
- One primary CTA per page
- Locale-correct currency formatting
- Every numeric claim cites `verified_claims.json`
- No DMCA red flags ("official Netflix", broadcaster logo lockups, etc.)

## What this skill does NOT do

- Doesn't pull Semrush data directly (that's the `seo-data-store` skill)
- Doesn't write content (that's the `iptv-seo-writer` agent)
- Doesn't write Astro code (that's the `iptv-tech-builder` agent)
- Doesn't deploy (that's the `/iptv-deploy` command)

Its job is to **route** — pick the right tool, then get out of the way.
