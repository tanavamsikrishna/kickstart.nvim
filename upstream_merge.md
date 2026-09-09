# Merging changes from upstream master

Runbook and decision log for pulling `nvim-lua/kickstart.nvim` (`upstream`) into
this fork (`origin`). "Merging" here means fetching `upstream` and translating
chosen changes into this tree — not a git merge or a cherry-pick. This fork's
layout (`lua/plugins/`, `lua/config/`) does not match the upstream template, so
each accepted change is ported by intent.

Skipping is normal. When in doubt, ask. Every decision (applied or skipped) is
recorded in the Log. Advance **Upstream through** to current `master@upstream`
only when that review is complete.

Workspace mechanics live in `scripts/upstream_merge.nu`
(`nu scripts/upstream_merge.nu --help`).

## Process

1. Read the latest **Upstream through** value from the Log (newest entry first).
2. `nu scripts/upstream_merge.nu prepare`
3. Present the pending changes (the upstream tree since the last merge) to the
   human, grouped by theme, with a recommended action (apply / skip / already
   present). Ask when unsure. Reprint with `nu scripts/upstream_merge.nu status`
   if needed.
4. Translate each accepted change into this tree. Do not cherry-pick upstream
   commits; commits are not the unit of work.
5. When the merge is complete, prepend a Log entry whose **Upstream through** is
   the full git id of current `master@upstream`, listing applied and skipped
   changes. Then `nu scripts/upstream_merge.nu finish`.

## Log

Newest entry first. The first **Upstream through** value is the last completed
review (a cursor into upstream history, not a unit of work). Use the full
40-character git commit id. Prefer one bullet per change (theme or intent), not
per upstream commit.

```
### YYYY-MM-DD — <short label>

- Upstream through: `<40-char git id>`
- Applied:
  - <change> — <how it was translated, with paths>
- Skipped:
  - <change> — <reason>
```

Use `Applied: none` or `Skipped: none` when that list is empty.

### 2026-05-07 — baseline

- Upstream through: `cfdc17be3ae1607d4427332de0b29d556f9dda13`
- Subject: Merge pull request #1982 from nathanzeng/jump-diagnostic
- Applied: none recorded (merges before this file were not logged)
- Skipped: none recorded
