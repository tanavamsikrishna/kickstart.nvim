-- Copy selected lines with filepath and filetype context to clipboard
vim.keymap.set('v', '<leader>yl', function()
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local filepath = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, '\n')

  local output = string.format(
    '*%s L%d:%d*\n\n```%s\n%s\n```',
    filepath,
    start_line,
    end_line,
    filetype,
    text
  )

  vim.fn.setreg('+', output)
  print('Copied lines ' .. start_line .. ' to ' .. end_line)
end, { desc = 'Copy selected lines with context to clipboard' })
