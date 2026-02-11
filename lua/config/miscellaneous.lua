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
vim.opt.titlestring = vim.fn.getcwd()

-- exrc
vim.o.exrc = true

-- virtualedit (for cursor movement)
vim.opt.virtualedit = { 'block' }

-- Abbrevations/Remappings
vim.keymap.set('ca', 'w', function()
  if vim.fn.getcmdtype() == ':' and vim.fn.getcmdline() == 'w' then
    return 'update'
  else
    return 'w'
  end
end, { expr = true })
