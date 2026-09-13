# Keybinding spec

How this config assigns keys. Lua maps are the runtime source of truth; this
file is the design contract. If they drift, change one of them on purpose.

This is not Neovim's, kickstart's, or a plugin's default layout. Prefixes have
meanings; new maps must fit those meanings.

## Prefixes

| Prefix | Means | Use for |
| --- | --- | --- |
| `g` | go to | Jump to a location or pick a symbol to jump to |
| `m` | modify | Semantic edits: comment, rename, code action, extract, … |
| `[` / `]` | prev / next | Adjacent instance of the same thing (diagnostic, hunk, reference, textobject) |
| `/` | search | Snacks pickers: files, grep, help, keymaps, … |
| `//` | search in buffer | Vim forward search |
| `<leader>` (`Space`) | command | Git, debug, toggles, diagnostics |
| `<localleader>` (`,`) | this buffer | Format, copy path / context |
| `F1`–`F7` | debugger | Session control (continue, step, UI) |

`g` and `m` are parallel single-letter prefixes. Other operator grammar stays
with the plugin or Vim: `ys`/`cs`/`ds` surround, `y`/`p` yank/put.

Vim `m{letter}` (set mark) is unused here. `M` stays “cursor to middle of
window.” Operator-pending `m` (e.g. `dma` delete-to-mark) is unmapped.
which-key does not auto-trigger on single-letter builtins except `g`/`z`, so
`m` and `/` are listed in `opts.triggers` as well as `spec`. Not in
operator-pending: `d/foo` and `dma` stay Vim motions.

## Rules

1. **`g` is go-to only.** If it does not land the cursor on a target (or open a
   picker whose job is to jump), it does not belong on `g`.
2. **`m` is modify only.** Semantic edits, including comments. Not navigation.
3. **A key is either a leaf or a prefix, never both.** Mapping `gr` as
   references forbids `gra`/`grr`/…. Mapping `ma` as code action forbids
   `ma*` maps. `mc`/`mb` *are* prefixes (comment operators + `mcc`/`mbc`).
   `/` is a prefix (`//` is in-buffer search). `<leader>v` is a leaf: do not
   add `<leader>v*` maps later.
4. **Prefer an existing group.** `/` search pickers, `<leader>h` git hunk,
   `<leader>t` toggle. Semantic edits go under `m`, not a new `<leader>`
   cluster. A new `<leader>` letter needs a which-key `group` if it will have
   more than one map.
5. **which-key groups exist only for real prefixes.** Do not invent a group
   whose only member is a command you wanted as a two-key chord.
6. **Always set `desc`.** Buffer-local for LSP and git-hunk maps.
7. **`nowait` on a leaf that used to be a prefix** (or might become one).
8. **Before adding a map:** `:verbose nmap <keys>`, `/k` (keymap picker),
   and the tables below. Do not override a builtin unless the spec already
   accepts that trade.

## Go-to (`g`)

LSP maps are buffer-local on `LspAttach`. `gj` is global.

| Keys | Action |
| --- | --- |
| `gd` | Definition |
| `gD` | Declaration |
| `gr` | References |
| `gi` | Implementation |
| `gt` | Type definition |
| `go` | Document symbols |
| `gw` | Workspace symbols |
| `gj` | Flash jump |

Neovim's global `gra`/`gri`/`grn`/`grr`/`grt`/`grx` are deleted so `gr` is a
leaf. Builtin `gc`/`gcc` are deleted so `g` is not a comment prefix. `K`
stays hover (Neovim LSP default).

Accepted builtin overrides on LSP buffers: `gd`/`gD` (declaration), `gr`
(virtual replace), `gi` (last insert), `gt` (next tab), `go` (byte offset),
`gw` (format). Tabs are not a navigation model here. `gj` (display-line
down) is global; arrows still use `gj`/`gk` when wrap is on.

## Modify (`m`)

| Keys | Action | Modes |
| --- | --- | --- |
| `ma` | Code action | `n`, `x` (`LspAttach`) |
| `mr` | Rename | `n` (`LspAttach`) |
| `mc{motion}` / `mcc` | Linewise comment | also `mco` / `mcO` / `mcA` |
| `mb{motion}` / `mbc` | Blockwise comment | |

Comments stay operators so `mcip` / `mc3j` work. Future extract / inline maps
go here (`me`, …).

## Other commands

| Keys | Action | Modes |
| --- | --- | --- |
| `<leader>d` | Diagnostic float | `n` |
| `<leader>q` | Diagnostic loclist | `n` |
| `<leader>v` | Visual: syntax node (Flash) | `n`, `x` |
| `<localleader>f` | Format buffer | `n` |

Format is style, not a semantic edit, so it stays on `<localleader>`.

## Search (`/`)

`/` is the picker family. `//` is Vim forward search in the current buffer
(`noremap` to the builtin). `?` stays backward search. Operator-pending `/`
(`d/foo`) is not a which-key trigger.

| Keys | Action |
| --- | --- |
| `//` | Vim search in buffer (`n`, `x`) |
| `/f` | Files |
| `/g` | Grep |
| `/w` | Grep word |
| `/.` | Recent files |
| `/n` | Neovim config files |
| `/h` | Help |
| `/k` | Keymaps |
| `/c` | Commands |
| `/d` | Diagnostics |
| `/s` | Select picker |
| `/r` | Resume last picker |
| `<leader>/` | Fuzzy lines in current buffer |
| `<leader><leader>` | Buffers |

## Other `<leader>` groups

| Keys | Group / action |
| --- | --- |
| `<leader>h*` | Git hunk (stage, reset, preview, blame, diff, quickfix) |
| `<leader>t*` | Toggle (`tb` blame, `tw` word diff) |
| `<leader>b` / `<leader>B` | Breakpoint / conditional breakpoint |
| `<leader>u` | Undo tree |
| `<leader>p` | Yank history |

## Prev / next

| Keys | Action |
| --- | --- |
| `[d` / `]d` | Diagnostic |
| `[c` / `]c` | Git hunk |
| `[r` / `]r` | LSP reference (Snacks words) |
| `[[` / `]]` | Function/class start |
| `[]` / `][` | Function/class end |
| `{` / `}` | Parameter / call / assignment / statement start |
| `[p` / `]p` | Put linewise with indent |

## `<localleader>` and the rest

| Keys | Action |
| --- | --- |
| `<localleader>f` | Format buffer |
| `<localleader>y` | Copy with filepath / filetype context |
| `<localleader>p` | Copy relative path |
| `\` | Explorer toggle |
| `\|` | Explorer reveal current file |
| `<C-h/j/k/l>` | Window focus |
| `<Esc>` | Clear search highlight (`n`); also exits some plugin UIs |
| `F5` / `F1` / `F2` / `F3` / `F7` | Debug continue / step into / over / out / UI |

## Adding a map

1. Classify it: go-to, modify, search, prev/next, command, this-buffer,
   operator, debugger. Semantic edits (including comments): `m`. Jumps: `g`.
   Pickers: `/` (`//` in-buffer). Syntax-node visual: `<leader>v` (not a
   `v…` chord).
2. Pick the prefix for that class. If none fits, that is a design change — edit
   this file first, then the Lua.
3. Check collisions (`:verbose nmap`, `/k`, this file).
4. Set `desc`. LSP/git: `{ buffer = ... }`. Leaf-vs-prefix: `nowait` if needed.
5. If you create a new `<leader>` cluster, register a which-key `group`.
