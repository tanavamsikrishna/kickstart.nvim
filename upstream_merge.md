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

### 2026-09-09 — gitsigns keymaps and config picker follow

- Upstream through: `f7b845d8b6df409b0392ca117d092d5dffd2b538`
- Applied:
  - Align gitsigns recommended keymaps with plugin defaults — `lua/plugins/gitsigns.lua`: `<leader>hD` diffs against `~` (was `@`), `<leader>hi` desc, `ih` textobject desc
  - Follow symlinks when searching Neovim config files — `lua/plugins/snacks.lua` `<leader>sn` (`follow = true`)
- Skipped:
  - GitHub issue templates, discussions links, and stylua CI — this tree has no `.github/`
  - README template-vs-fork guidance and Alpine install recipe — this tree's `Readme.md` is project-local variables, not the kickstart install guide
  - init.lua section comment split/renumber — this tree does not use those section banners
  - Switch nvim-web-devicons to mini.icons + `mock_nvim_web_devicons` — this tree already uses mini.icons and still depends on nvim-web-devicons for nvim-tree and render-markdown
  - lua_ls library path / settings typing — this tree uses lazydev, not kickstart's lua_ls library table
  - mason-lspconfig.setup (`automatic_enable = false`) — this tree does not use Mason
  - Example LSP `ts_ls` → `tsc` — this tree uses `vtsls`
  - custom.plugins loader (symlink follow, unspecified load order) — this tree uses lazy.nvim `{ import = 'plugins' }`
  - neo-tree always packing nvim-web-devicons — this tree uses nvim-tree, not neo-tree
  - Enable gitsigns recommended keymaps by default / drop optional `kickstart.plugins.gitsigns` — already present in `lua/plugins/gitsigns.lua`

### 2026-05-07 — baseline

- Upstream through: `cfdc17be3ae1607d4427332de0b29d556f9dda13`
- Subject: Merge pull request #1982 from nathanzeng/jump-diagnostic
- Applied: none recorded (merges before this file were not logged)
- Skipped: none recorded
