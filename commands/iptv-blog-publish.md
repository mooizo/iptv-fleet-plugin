---
description: Lists current draft blogs for a country site and flips selected drafts to published (without auto-committing). Usage:/iptv-blog-publish {COUNTRY_CODE}
argument-hint: "{country-code} (e.g. NL)"
---

# /iptv-blog-publish {country}

CLI helper to publish drafts without leaving the terminal. Lists all drafts in `sites/{cc-lower}/src/content/blog/`, lets you pick one or more, flips their `status: draft` → `status: published` in frontmatter, prints the exact `git` commands to commit.

**Does NOT auto-commit.** You see the change first, then commit yourself. This preserves the human-in-the-loop discipline.

Power-user alternative to Decap CMS — same end result.

## What to do

### 1. Validate
- Argument: ISO-3166 alpha-2 (e.g. `NL`)
- Verify `sites/{cc-lower}/` exists

### 2. List drafts

Scan `sites/{cc-lower}/src/content/blog/*.md`. For each file:
- Parse frontmatter (regex on `^status:\s*draft\s*$`)
- Skip files where status is `published`
- Collect `{filename, primary_keyword, date, title}` for each draft

If zero drafts: print "No drafts found in sites/{cc-lower}/src/content/blog/. Run /iptv-blog-new {cc} to create one."

### 3. Present the list

```
Drafts in sites/nl/src/content/blog/:

  1. iptv-eredivisie-2026.md
     Title: Eredivisie in 2026 via IPTV: complete gids
     Primary kw: iptv eredivisie 2026
     Date: 2026-05-27

  2. iptv-smart-tv-2026.md
     Title: ...
     ...

Which to publish? (number, comma-separated for multiple, or "all" or "cancel")
```

Use `AskUserQuestion` for the selection.

### 4. Flip status

For each selected file:
- Open the .md file
- Replace `^status:\s*draft\s*$` (multiline regex) with `status: published`
- Also add `updated_date: <today UTC YYYY-MM-DD>` IF the field doesn't already exist (and the file's `date` field is more than 1 day in the past)
- Write back

### 5. Print git commands (do NOT execute)

```
✓ Flipped 2 drafts to published

Files modified:
  sites/nl/src/content/blog/iptv-eredivisie-2026.md
  sites/nl/src/content/blog/iptv-smart-tv-2026.md

To commit and trigger Cloudflare deploy:

  cd ~/Code/iptv-fleet
  git add sites/nl/src/content/blog/
  git diff --cached    # review the change
  git commit -m "content(nl): publish 2 blog posts"
  git push

After push, Cloudflare Pages rebuilds in ~90 seconds. Live at:
  https://iptvhelder.nl/blog/iptv-eredivisie-2026/
  https://iptvhelder.nl/blog/iptv-smart-tv-2026/
```

### 6. Suggest next steps

If the user has 2+ drafts remaining unpublished, suggest:
> "You have 3 more drafts. Run `/iptv-blog-publish NL` again to publish more, or batch-publish by scheduling them across days (recommended for steady Google freshness signals)."

## Hard rules

- **Never run `git commit` or `git push`** — leave that for the user
- **Always re-read the file** before flipping — don't rely on stale cached state
- **Preserve the rest of frontmatter exactly** — only touch the `status` line + add `updated_date` if appropriate
- **Skip files without YAML frontmatter** — print a warning but don't error
- **Default to "show me, don't change anything"** if the user types "cancel"
