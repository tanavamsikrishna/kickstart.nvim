--- Line/block comment toggling (Comment.nvim).
---
--- Lives on the modify prefix: `mc`/`mcc` linewise, `mb`/`mbc` blockwise,
--- plus `mco`/`mcO`/`mcA`. Neovim's builtin `gc`/`gcc` are removed so `g`
--- stays go-to only. See `keybindings.md`.

return {
  'numToStr/Comment.nvim',
  opts = {
    toggler = { line = 'mcc', block = 'mbc' },
    opleader = { line = 'mc', block = 'mb' },
    extra = { above = 'mcO', below = 'mco', eol = 'mcA' },
  },
  init = function()
    -- Neovim 0.10+ maps gc/gcc globally. See :help gc-default.
    pcall(vim.keymap.del, { 'n', 'x' }, 'gc')
    pcall(vim.keymap.del, 'n', 'gcc')
    pcall(vim.keymap.del, 'o', 'gc')
  end,
}
