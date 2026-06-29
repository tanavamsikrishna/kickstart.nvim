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

-- Abbreviations/Remapping
vim.keymap.set('ca', 'w', function()
  if vim.fn.getcmdtype() == ':' and vim.fn.getcmdline() == 'w' then
    return 'update'
  else
    return 'w'
  end
end, { expr = true })

-- Page down/up
---@param direction boolean
local function _page_up_down_move(direction)
  local absolute_move = 20
  local move = (direction and 1 or -1) * absolute_move
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line_count = vim.api.nvim_buf_line_count(0)
  local target_location = math.min(line_count, math.max(1, row + move))
  vim.api.nvim_win_set_cursor(0, { target_location, col })
end

vim.keymap.set('n', '<PageUp>', function() _page_up_down_move(false) end)
vim.keymap.set('n', '<PageDown>', function() _page_up_down_move(true) end)
