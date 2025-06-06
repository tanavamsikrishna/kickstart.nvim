local M = {}

--- @param pwd string
--- @param full_file_path string
--- @param line string
--- @return integer row, integer col
local function parse_line(pwd, full_file_path, line)
  -- /Users/vamsi/repo/stocks/system_trading/options_intraday/utils/read_tick_data_from_log.py:21:54 - error: "group" is not a known attribute of "None" (reportOptionalMemberAccess)
end

function M.open_file(pwd, file, whole_line)
  print(vim.inspect { pwd, file, whole_line })
  if not vim.g.neovide then
    vim.notify 'Trying to open a file using `terminal_link_handler`. But this is not neovide'
  end
  vim.api.nvim_cmd({ cmd = 'e', args = { file } }, {})
  -- vim.fn.cursor(row, column)
  vim.api.nvim_cmd({ cmd = 'NeovideFocus' }, {})
end

return M
