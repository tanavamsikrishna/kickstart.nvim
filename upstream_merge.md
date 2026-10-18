# Merging changes from upstream master

Runbook and decision log for pulling `nvim-lua/kickstart.nvim` (`upstream`)
into this fork (`origin`).

Port chosen changes into this tree by intent. Layouts differ (`lua/plugins/`
and `lua/config/` vs the upstream template), so do not cherry-pick or
content-merge. Skip freely. When in doubt, ask. Record every decision in the
Log, and advance **Upstream through** to current `master@upstream` only when
the review is done.

`finish` then writes one merge commit: first parent is the previous origin
tip, second parent is `master@upstream`, tree is ours. Git does not choose
hunks. Do not `git merge` or `jj new` the two masters yourself. Mechanics:
`nu scripts/upstream_merge.nu`.

## Process

1. Read the latest **Upstream through** value from the Log (newest entry first).
2. `nu scripts/upstream_merge.nu prepare`
3. Present pending changes, grouped by theme, with a recommended action
   (apply / skip / already present). Ask when unsure. Reprint with
   `nu scripts/upstream_merge.nu status`.
4. Port accepted changes into this tree.
5. Prepend a Log entry whose **Upstream through** is the full git id of
   current `master@upstream`. Then `nu scripts/upstream_merge.nu finish`.

`finish` refuses until the Log pointer equals `master@upstream`. If that
commit is already an ancestor, it does not add a parent. If the Log already
matches, the working copy is empty, and upstream is not yet an ancestor,
`finish` records the merge with no tree change and no new Log entry. An empty
working copy is otherwise refused.

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

### 2026-10-17 — treesitter buffer validity

- Upstream through: `8e35dbedb7966e3a95e1f26f9fc1179ab6c68db4`
- Applied: none
- Skipped:
  - Guard Treesitter attach when a buffer is wiped during async parser install — already present in `lua/plugins/treesitter.lua`: validity is checked before install and again after `ts.install`, before `vim.treesitter.start` and indent. Upstream later moved that guard to before `language.add` so a wiped buffer skips loading the parser; `language.add` does not use the buffer, so this tree still loads it.
  - EmmyLua spacing in upstream `init.lua` (doc-comment space, `(string | vim.pack.Spec)`) — this tree has no `gh()` helper and does not install Telescope through `vim.pack`

### 2026-09-09 — gitsigns keymaps and config picker follow

- Upstream through: `f7b845d8b6df409b0392ca117d092d5dffd2b538`
- Applied:
  - Align gitsigns recommended keymaps with plugin defaults — `lua/plugins/gitsigns.lua`: `<leader>hD` diffs against `~` (was `@`), `<leader>hi` desc, `ih` textobject desc
  - Follow symlinks when searching Neovim config files — `lua/plugins/snacks.lua` `/n` (`follow = true`)
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
