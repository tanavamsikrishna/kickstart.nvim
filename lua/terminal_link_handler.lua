local M = {}

function M.open_file(pwd, file, whole_line)
  if not vim.g.neovide then
    vim.notify 'Trying to open a file using `terminal_link_handler`. But this is not neovide'
  end
  vim.api.nvim_cmd({ cmd = 'e', args = { file } }, {})
  -- vim.fn.cursor(row, column)
  vim.api.nvim_cmd({ cmd = 'NeovideFocus' }, {})
end

return M
