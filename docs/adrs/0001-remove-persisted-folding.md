# ADR 0001: Remove persisted folding and the custom fold toggle

- Status: Accepted
- Date: 2026-11-13

## Context

Files are frequently edited outside Neovim, including by AI harnesses. Saved views contain line-based fold ranges that can become stale when external edits insert, delete, or move text. Restoring those views can therefore fold the wrong regions rather than reflect the current file structure.

`lua/config/viewoptions.lua` automatically saved and restored folds and cursor positions with `:mkview` and `:loadview`. `lua/config/folding.lua` overrode `za` to create a manual fold from a Treesitter node when no existing fold could be toggled, then persisted that view.

The custom creation behavior is redundant: the existing `<leader>v` mapping selects a syntax node through Flash, and native Visual-mode `zf` creates a fold from that selection.

## Decision

- Stop automatically saving and restoring per-file views through these modules.
- Use `<leader>v`, choose the desired syntax-node selection, then press `zf` to create a manual fold from the current text.
- Leave `za` as Neovim's native toggle for an existing fold, without a custom Treesitter fallback.

Do not replace persistence with external-edit detection or fold-range repair. Explicitly selecting the current syntax node is simpler and avoids restoring stale line ranges.

## Consequences

- Fold creation uses the existing selection interface and native commands.
- Folds are temporary; this configuration no longer automatically restores them from per-file views.
- Automatic cursor-position restoration supplied by the removed view module is also removed.
- Existing view files are left on disk, but these modules no longer load them.
- This does not make live manual folds resilient to external edits. If they no longer match the text, recreate them from a fresh selection.

## References

- `lua/plugins/flash.lua`: existing `<leader>v` syntax-node selection.
- `:help fold-manual` and `:help v_zf`: native manual-fold creation.
- `:help usr_28.4`: saved views can become invalid after lines change.
