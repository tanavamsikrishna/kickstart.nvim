--- Yank ring with sqlite-backed history (yanky.nvim).
---
--- Remaps `y`/`p`/`P`; `<c-p>`/`<c-n>` cycle history after put; `<leader>p`
--- opens the history picker. `]p`/`[p` put linewise with indent.

return {
  'gbprod/yanky.nvim',
  dependencies = {
    { 'kkharji/sqlite.lua' },
  },
  opts = {
    ring = { storage = 'sqlite' },
  },
  keys = {
    {
      '<leader>p',
      '<cmd>YankyRingHistory<cr>',
      mode = { 'n', 'x' },
      desc = 'Open Yank History',
    },
    { 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank text' },
    {
      'p',
      '<Plug>(YankyPutAfter)',
      mode = { 'n', 'x' },
      desc = 'Put yanked text after cursor',
    },
    {
      'P',
      '<Plug>(YankyPutBefore)',
      mode = { 'n', 'x' },
      desc = 'Put yanked text before cursor',
    },
    {
      '<c-p>',
      '<Plug>(YankyPreviousEntry)',
      desc = 'Select previous entry through yank history',
    },
    {
      '<c-n>',
      '<Plug>(YankyNextEntry)',
      desc = 'Select next entry through yank history',
    },
    {
      ']p',
      '<Plug>(YankyPutIndentAfterLinewise)',
      desc = 'Put indented after cursor (linewise)',
    },
    {
      '[p',
      '<Plug>(YankyPutIndentBeforeLinewise)',
      desc = 'Put indented before cursor (linewise)',
    },
  },
}
