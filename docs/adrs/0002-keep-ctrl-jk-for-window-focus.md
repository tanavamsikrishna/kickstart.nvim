# ADR 0002: Keep Ctrl-J and Ctrl-K for window focus

- Status: Accepted
- Date: 2026-11-16

## Context

Normal-mode `j` is the picker prefix, so it is not a line motion. Cursor movement is arrows. `lua/config/movement.lua` maps `jj` and `kk` in normal and visual mode to a display-line motion when there is no count, and a buffer-line motion when there is. Those maps are non-recursive, so they hit the builtin motions rather than Flash on `gj` or the `j` picker prefix. Operator-pending `j` stays a motion (`dj`, `mc3j`).

`<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>` move focus between windows. That family is the contract in `keybindings.md`.

`<C-j>` and `<C-k>` were considered as up/down line movement, to replace or supplement arrows and `jj`/`kk`.

## Decision

Do not map `<C-j>` or `<C-k>` to line movement. Keep them as window focus, with `<C-h>` and `<C-l>`.

Line movement stays arrows, plus `jj`/`kk` for the count-aware display-line behavior in `movement.lua`. Do not add a third vertical pair on these chords, in any mode.

`<C-j>` is newline in a terminal. Neovim treats it as `j` in normal mode and as `<CR>` in insert and command-line, so it is not a free key and is not reliably distinct from Enter outside a GUI. `<C-k>` is unused in normal mode, but it enters digraphs in insert and on the command line. The builtin normal-mode pair is `<C-j>`/`<C-n>` down and `<C-p>` up, not `<C-j>`/`<C-k>`. A ctrl chord is also a poor primary motion: counts and repetition are worse than a bare key, and it is not an operator motion unless operator-pending mode is mapped too.

## Consequences

- Vertical split navigation stays on the same `<C-hjkl>` family as horizontal navigation.
- `<C-j>` is not overloaded onto a key that terminals identify as newline.
- Insert-mode and command-line digraph entry on `<C-k>` stay available.
- Operators keep using `j`/`k`, not these chords.
- Anyone who wants line movement uses arrows or `jj`/`kk`, not `<C-j>`/`<C-k>`.

## References

- `init.lua`: `<C-j>` and `<C-k>` window-focus maps.
- `keybindings.md`: `<C-h/j/k/l>` window focus; normal-mode `j` is a picker prefix; operator-pending `j` stays a motion.
- `lua/config/movement.lua`: `jj` and `kk`.
- `:help CTRL-J`, `:help i_CTRL-J`, `:help c_CTRL-J`, `:help i_CTRL-K`.
