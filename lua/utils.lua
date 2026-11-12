-- Read and write JSON state under stdpath('state')/<folder>-<cwd-hash>/.
-- Paths use the normalized current CWD; helpers return nil plus an error on failure.
local M = {}

local function cwd_state_file(filename)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local folder = vim.fs.basename(cwd):gsub('[^%w%-_]', '_')
  local hash = vim.fn.sha256(cwd):sub(1, 12)
  return vim.fn.stdpath 'state'
    .. '/projects/'
    .. folder
    .. '-'
    .. hash
    .. '/'
    .. filename
end

---@param filename string
---@return any data
---@return string? error
function M.read_cwd_json(filename)
  local ok, lines = pcall(vim.fn.readfile, cwd_state_file(filename))
  if not ok then return nil, tostring(lines) end
  local decoded, data = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not decoded then return nil, tostring(data) end
  return data
end

---@param filename string
---@param data any
---@return boolean? success
---@return string? error
function M.write_cwd_json(filename, data)
  local encoded, content = pcall(vim.json.encode, data)
  if not encoded then return nil, tostring(content) end
  local path = cwd_state_file(filename)
  local created, err = pcall(vim.fn.mkdir, vim.fs.dirname(path), 'p')
  if not created then return nil, tostring(err) end
  local written, result = pcall(vim.fn.writefile, { content }, path)
  if not written then return nil, tostring(result) end
  if result ~= 0 then return nil, 'Could not write ' .. path end
  return true
end

return M
