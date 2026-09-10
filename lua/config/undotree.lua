--- Enable Neovim's optional `nvim.undotree` pack and bind a toggle keymap.
---
--- Opens (or closes) a side window showing this buffer's undo branches as a
--- git-style graph. Cursor movement in that window applies the corresponding
--- undo state.

vim.cmd 'packadd nvim.undotree'
vim.keymap.set(
  'n',
  '<leader>u',
  function() require('undotree').open { title = 'Undo tree' } end,
  { desc = 'Toggle undo tree' }
)
