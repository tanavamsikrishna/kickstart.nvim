# ADR 0002: Map Ctrl-J and Ctrl-K to up and down

- Status: Rejected
- Date: 2026-11-16

## Context

Normal-mode `j` is the picker prefix, so it is not a line motion. `<C-j>` and `<C-k>` were considered as up and down instead.

## Decision

Rejected. Do not map `<C-j>` or `<C-k>` to line movement.

They are the vertical half of window focus, with `<C-h>` and `<C-l>`. `<C-j>` is newline in a terminal. Neovim treats it as `j` in normal mode and as `<CR>` in insert and command-line, so it is not reliably distinct from Enter outside a GUI. `<C-k>` enters digraphs in insert and on the command line. A ctrl chord is also a poor primary motion: counts and repetition are worse than a bare key, and it is not an operator motion unless operator-pending mode is mapped too.
