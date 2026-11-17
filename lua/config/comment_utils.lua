--- Comment delimiters for a line range, from Comment.nvim.
---
--- `comment_delimiters` prefers a block comment when the language has one,
--- otherwise the line comment. The range is not because lines of one language
--- differ. It lets Treesitter pick an injected language in a single file that
--- holds several (a Lua fence in Markdown, a `<script>` block in Vue). Without
--- that, the buffer filetype would choose, and a Python fence would be asked
--- for a block comment it does not have. Treesitter failure falls back to
--- Comment.nvim's filetype table, then `'commentstring'`. Columns are ignored.
--- Not a plugin spec and not loaded from `init.lua`; callers require it.

local M = {}

local U = require 'Comment.utils'

---@param line1 integer
---@param line2 integer
---@param ctype integer
---@return string|nil
local function calculate(line1, line2, ctype)
  local ft = require 'Comment.ft'
  ---@type CommentCtx
  local ctx = {
    ctype = ctype,
    cmode = U.cmode.comment,
    cmotion = U.cmotion.line,
    range = { srow = line1, scol = 0, erow = line2, ecol = 0 },
  }
  local ok, cstr = pcall(ft.calculate, ctx)
  if ok then return type(cstr) == 'string' and cstr or nil end
  local fallback = ft.get(vim.bo.filetype, ctype)
  if type(fallback) == 'string' then return fallback end
end

--- Left and right sides of a `%s` commentstring, or nothing if it is unusable.
---@param cstr string|nil
---@return string|nil left
---@return string|nil right
local function parts(cstr)
  if type(cstr) ~= 'string' or not cstr:find('%s', 1, true) then return end
  return U.unwrap_cstr(cstr)
end

--- 'block' or 'line'. Nil when the buffer has no commentstring.
---@param line1 integer
---@param line2 integer
---@return 'block'|'line'|nil
local function comment_kind(line1, line2)
  local _, right = parts(calculate(line1, line2, U.ctype.blockwise))
  if right and right ~= '' then return 'block' end
  local line = calculate(line1, line2, U.ctype.linewise) or vim.bo.commentstring
  if parts(line) then return 'line' end
end

--- Left and right comment delimiters for a line range.
--- Right is empty when the language has no block comment.
---@param line1 integer 1-indexed
---@param line2 integer 1-indexed, inclusive
---@return string left
---@return string right
function M.comment_delimiters(line1, line2)
  if comment_kind(line1, line2) == 'block' then
    local left, right = parts(calculate(line1, line2, U.ctype.blockwise))
    return left or '', right or ''
  end
  local left = parts(calculate(line1, line2, U.ctype.linewise) or vim.bo.commentstring)
  return left or '', ''
end

return M
