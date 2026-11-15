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
| `f` | jump (with picker) | Pickers: files, grep, help, keymaps, … |
| `[` / `]` | prev / next | Adjacent instance of the same thing (diagnostic, hunk, textobject) |
| `<leader>` (`Space`) | command | Git, debug, toggles, diagnostics |
| `<localleader>` (`,`) | this buffer | Format, copy path / context |
| `F1`–`F7` | debugger | Session control (continue, step, UI) |

mini.clue in `lua/plugins/mini.lua` triggers `g`, `m`, normal `f`, `[`/`]`,
and `<leader>`. Group clues: `<leader>h` Git hunk, `<leader>t` Toggle.
Do not trigger `<localleader>`: `,` stays Flash char-mode. Leaf text is
keymap `desc`. A new group needs a clue there, not only a row here.

`g`, `m`, and `f` are parallel single-letter prefixes. Other operator grammar
stays with the plugin or Vim: `ys`/`cs`/`ds` surround, `y`/`p` yank/put.

Vim `m{letter}` (set mark) is unused here. `M` stays “cursor to middle of
window.” Operator-pending `m` (e.g. `dma` delete-to-mark) is unmapped.
Normal-mode `f` is a prefix (do not map `f` itself). `F` is Flash jump, not
Vim find-backward. `j` is not a prefix; `jj` is the count-aware display-line
motion. `J` stays join. `/` and `?` stay Vim search. `d/foo`, `dj`, and `dma`
stay Vim motions.

## Rules

1. **`g` is go-to only.** If it does not land the cursor on a target (or open a
   picker whose job is to jump), it does not belong on `g`.
2. **`m` is modify only.** Semantic edits, including comments. Not navigation.
3. **A key is either a leaf or a prefix, never both.** Mapping `gr` as
   references forbids `gra`/`grr`/…. Mapping `ma` as code action forbids
   `ma*` maps. `mc`/`mb` *are* prefixes (comment operators + `mcc`/`mbc`).
   `f` is a prefix (do not map `f` itself). `F` is a leaf (Flash jump): do not
   add `F*` maps. `/` is a leaf (Vim search).
   `<leader>v` is a leaf: do not add `<leader>v*` maps later.
4. **Prefer an existing group.** `f` pickers, `<leader>h` git hunk,
   `<leader>t` toggle. Semantic edits go under `m`, not a new `<leader>`
   cluster. A new `<leader>` letter is a prefix only if it will have more
   than one map.
5. **Always set `desc`.** Buffer-local for LSP and git-hunk maps.
6. **`nowait` on a leaf that used to be a prefix** (or might become one).
7. **Before adding a map:** `:verbose nmap <keys>`, `fk` (keymap picker),
   and the tables below. Do not override a builtin unless the spec already
   accepts that trade.

## Go-to (`g`)

LSP maps are buffer-local on `LspAttach`. Flash jump is `F` (`n`, `x`, `o`),
not under `g`.

| Keys | Action |
| --- | --- |
| `gd` | Definition |
| `gD` | Declaration |
| `gr` | References |
| `gi` | Implementation |
| `gt` | Type definition |
| `go` | Document symbols |
| `gw` | Workspace symbols |

Neovim's global `gra`/`gri`/`grn`/`grr`/`grt`/`grx` are deleted so `gr` is a
leaf. Builtin `gc`/`gcc` are deleted so `g` is not a comment prefix. `K`
stays hover (Neovim LSP default).

Accepted builtin overrides on LSP buffers: `gd`/`gD` (declaration), `gr`
(virtual replace), `gi` (last insert), `gt` (next tab), `go` (byte offset),
`gw` (format). Tabs are not a navigation model here. `F` (find-backward) is
global. `gj`/`gk` stay display-line motions; arrows still use them when wrap
is on. Flash char-mode still binds `t` / `T` / `;` / `,`.

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
| `F` | Flash jump | `n`, `x`, `o` |
| `<leader>v` | Visual: syntax node (Flash) | `n`, `x` |
| `<localleader>f` | Format buffer | `n` |

Format is style, not a semantic edit, so it stays on `<localleader>`.

## Jump with picker (`f`)

`f` is the picker family. Not every map is a literal jump (help, keymaps,
resume). Precise go-to (definition) stays on `g`. Flash jump is `F`.
`/` and `?` are Vim search. Operator-pending `j` (`dj`, `mc3j`) stays a motion.
Word search is fff `fw`, not mini.pick.

| Keys | Action |
| --- | --- |
| `ff` | Files |
| `fg` | Grep (plain, regex, fuzzy, definition) |
| `fz` | Grep (fuzzy, plain only) |
| `fw` | Grep word / selection (fff) |
| `f.` | Recent files |
| `fn` | Neovim config files |
| `fh` | Help |
| `fk` | Keymaps |
| `fc` | Commands |
| `fd` | Diagnostics |
| `fr` | Resume last picker |
| `fb` | Buffers |

## Other `<leader>` groups

| Keys | Group / action |
| --- | --- |
| `<leader>h*` | Git hunk (stage, reset, preview, blame, diff, quickfix) |
| `<leader>t*` | Toggle (`tb` blame, `tw` word diff) |
| `<leader>b` / `<leader>B` | Breakpoint / conditional breakpoint |
| `<leader>u` | Undo tree |
| `<leader>p` | Yank history |
| `<leader>n` | Clear notifications |

## Prev / next

| Keys | Action |
| --- | --- |
| `[d` / `]d` | Diagnostic |
| `[c` / `]c` | Git hunk |
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

1. Classify it: go-to, modify, jump-with-picker, prev/next, command,
   this-buffer, operator, debugger. Semantic edits (including comments): `m`.
   Jumps to a target: `g`. Flash jump is already `F`. Pickers: `f`.
   In-buffer search: `/`/`?`.
   Syntax-node visual: `<leader>v` (not a `v…` chord).
2. Pick the prefix for that class. If none fits, that is a design change — edit
   this file first, then the Lua.
3. Check collisions (`:verbose nmap`, `fk`, this file).
4. Set `desc`. LSP/git: `{ buffer = ... }`. Leaf-vs-prefix: `nowait` if needed.
   A new group also needs a mini.clue group clue in `lua/plugins/mini.lua`.
