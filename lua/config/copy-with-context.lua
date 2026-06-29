--- Copy lines with filepath and filetype context to clipboard
---@param start_line integer
---@param end_line integer
local function copy_with_context(start_line, end_line)
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local filepath = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, '\n')

  local output =
    string.format('*%s L%d:%d*\n```%s\n%s\n```', filepath, start_line, end_line, filetype, text)

  vim.fn.setreg('+', output)
  print('Copied lines ' .. start_line .. ' to ' .. end_line)
end

local context_copy_keymap = '<localleader>y'

vim.keymap.set('n', context_copy_keymap, function()
  local line = vim.fn.line '.'
  copy_with_context(line, line)
end, { desc = 'Copy current line with context to clipboard' })

vim.keymap.set('v', context_copy_keymap, function()
  copy_with_context(vim.fn.line 'v', vim.fn.line '.')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nt', false)
end, { desc = 'Copy selected lines with context to clipboard' })

-- Copy relative path to system clipboard
vim.keymap.set('n', '<localleader>p', function()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  vim.notify('Copied relative path: ' .. path)
end, { desc = 'Copy relative file path' })
