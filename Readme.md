# Project-local variables

Set these in a project's `.nvim.lua` (`'exrc'` is on).

## `disable_autoformat` (`g` and `b`)

Skip format-on-save. `<localleader>f` still formats.

Unset (falsy) means format-on-save runs. Either scope being truthy skips it.
Marimo Python notebooks (`app = marimo.App` in the first five lines) set `b`
automatically.

```lua
vim.g.disable_autoformat = true
vim.b.disable_autoformat = true
```

## `lazydev_enabled` (`g` only)

Enable lazydev.nvim for Lua: Neovim runtime, plugin, and `vim.uv` types in
`lua_ls`. Must be the boolean `true`; anything else leaves it off. Use in
Neovim-config / plugin repos (this one sets it).

```lua
vim.g.lazydev_enabled = true
```

## `frontend_file_formatter` (`g` only)

Conform formatter for css, javascript, and typescript. Defaults to
`'biome-check'`.

```lua
vim.g.frontend_file_formatter = 'prettierd'
```
