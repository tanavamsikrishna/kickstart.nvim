-- Fix UI issues
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    -- vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { bold = true })
    -- vim.api.nvim_set_hl(0, 'DiagnosticFloatingHint', { link = 'DiagnosticFloatingInfo' })
    -- vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { foreground = 'darkgreen' })
    -- vim.api.nvim_set_hl(0, 'MatchParen', { bold = true, fg = 'black', underline = true })
  end,
})

-- Set title to the current working directory
vim.opt.title = true
vim.opt.titlestring = 'Neovide ' .. vim.fn.getcwd()

-- `exrc`
vim.o.exrc = true

-- wrapping
vim.o.wrap = true
vim.opt.linebreak = false

local linebreak_filetypes = { 'markdown', 'quarto', 'rmd', 'text', 'gitcommit' }

vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter', 'WinEnter' }, {
  desc = 'Use linebreak only for prose windows',
  group = vim.api.nvim_create_augroup('ProseLinebreak', { clear = true }),
  callback = function()
    vim.opt_local.linebreak = vim.tbl_contains(linebreak_filetypes, vim.bo.filetype)
  end,
})

-- `virtualedit` (for cursor movement)
vim.opt.virtualedit = { 'block' }

-- Perfect page scrolling: old bottom+1 becomes new top (and symmetric for up)
vim.keymap.set({ 'n', 'v' }, '<PageDown>', function()
  local bot = vim.fn.line 'w$'
  local new_top = math.min(bot + 1, vim.api.nvim_buf_line_count(0))
  vim.api.nvim_win_set_cursor(0, { new_top, 0 })
  vim.cmd 'normal! zt'
end, { desc = 'Page down' })

vim.keymap.set({ 'n', 'v' }, '<PageUp>', function()
  local top = vim.fn.line 'w0'
  local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local height = vim.api.nvim_win_get_height(0) - (wininfo.winbar or 0)
  local new_top = math.max(top - height, 1)
  vim.api.nvim_win_set_cursor(0, { new_top, 0 })
  vim.cmd 'normal! zt'
end, { desc = 'Page up' })

-- Abbreviations/Remapping
vim.keymap.set('ca', 'w', function()
  if vim.fn.getcmdtype() == ':' and vim.fn.getcmdline() == 'w' then
    return 'update'
  else
    return 'w'
  end
end, { expr = true })
