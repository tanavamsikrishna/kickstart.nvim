local M = {}

--- @param value string
--- @return integer
local function str_to_int(value)
  return math.floor(tonumber(value) or 0)
end

--- @param full_file_path string
--- @param line string
--- @return integer row, integer col
local function parse_line(full_file_path, line)
  -- /Users/vamsi/repo/stocks/system_trading/options_intraday/utils/read_tick_data_from_log.py:21:54 - error: "group" is not a known attribute of "None" (reportOptionalMemberAccess)
  local row, col = line:match('.*' .. full_file_path .. ':(%d+):(%d+) - .*')
  if row and col then
    return str_to_int(row), str_to_int(col)
  end

  -- File "/Users/vamsi/repo/playground/scratch.py", line 2, in func
  local row = line:match('.*File "' .. full_file_path .. '", line (%d+),.*')
  if row then
    return str_to_int(row), 0
  end
  return 0, 0
end

function M.open_file(pwd, file, whole_line)
  if not vim.g.neovide then
    vim.notify 'Trying to open a file using `terminal_link_handler`. But this is not neovide'
  end
  vim.api.nvim_cmd({ cmd = 'e', args = { file } }, {})
  local row, col = parse_line(file, whole_line)
  vim.fn.cursor(row, col)
  vim.api.nvim_cmd({ cmd = 'NeovideFocus' }, {})
end

return M
