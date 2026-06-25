-- Spec: when files change externally, Neovim's autoread only reloads the
-- buffer currently being viewed; buffers open but not focused stay stale,
-- so their LSP symbols/diagnostics drift out of sync with disk. Force a
-- `:checktime` on focus/entry/idle events so every buffer gets a chance to
-- reload (and its LSP state to refresh) as soon as it becomes active.

vim.o.autoread = true

vim.api.nvim_create_autocmd(
  { 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' },
  {
    pattern = '*',
    callback = function()
      if vim.fn.mode() ~= 'c' then vim.cmd 'checktime' end
    end,
  }
)
