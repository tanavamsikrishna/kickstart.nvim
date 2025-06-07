local M = {}

--- @param value string
--- @return integer
local function str_to_int(value)
  return math.floor(tonumber(value) or 0)
end

--- @param pwd string
--- @param full_file_path string
--- @param line string
--- @return integer row, integer col
local function parse_line(pwd, full_file_path, line)
  local relative_file_path = vim.fs.relpath(pwd, full_file_path)

  -- File "/Users/vamsi/repo/playground/scratch.py", line 2, in func
  local row = line:match('%s*File "' .. full_file_path .. '", line (%d+),.*')
  if row then
    return str_to_int(row), 0
  end

  -- test/test.py:11:8: F401 [*] `json` imported but unused
  --   --> src/main.rs:51:31
  -- /Users/vamsi/repo/stocks/system_trading/options_intraday/utils/read_tick_data_from_log.py:21:54 - error: "group" ...
  local row, col = line:match(relative_file_path .. ':(%d+):(%d+)')
  if row then
    return str_to_int(row), str_to_int(col)
  end

  return 0, 0
end

--- @param pwd string
--- @param full_file_path string
--- @param whole_line string
function M.open_file(pwd, full_file_path, whole_line)
  -- print(vim.inspect { pwd, full_file_path, whole_line })
  if not vim.g.neovide then
    vim.notify 'Trying to open a file using `terminal_link_handler`. But this is not neovide'
  end
  vim.api.nvim_cmd({ cmd = 'e', args = { full_file_path } }, {})
  local row, col = parse_line(pwd, full_file_path, whole_line)
  vim.fn.cursor(row, col)
  vim.api.nvim_cmd({ cmd = 'NeovideFocus' }, {})
end

return M
