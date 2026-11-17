--- Wrap whole lines in a commented ai-todo block (`:AiTodo`).
---
--- Writes the tags around the range, then comments that range with Comment.nvim:
--- `api.comment.blockwise` when the language has a block comment, otherwise
--- `api.comment.linewise`. Tag lines are not indented.

local M = {}

--- Replace [line1, line2] with a commented ai-todo block.
---@param line1 integer
---@param line2 integer
function M.wrap_range(line1, line2)
  if line1 > line2 then
    line1, line2 = line2, line1
  end

  local delimiters = require 'config.comment_utils'
  local left, right = delimiters.comment_delimiters(line1, line2)
  if left == '' then
    vim.notify('AiTodo: no commentstring for ' .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  -- Split so a todo-keyword scan of this file does not match the marker.
  local body = { '<' .. 'ai-todo>' }
  for _, line in ipairs(lines) do
    body[#body + 1] = line
  end
  body[#body + 1] = '<' .. '/ai-todo>'

  vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, body)
  vim.api.nvim_win_set_cursor(0, { line1, 0 })

  local comment = require('Comment.api').comment
  local count = #body
  if right ~= '' then
    comment.blockwise.count(count)
  else
    comment.linewise.count(count)
  end
end

vim.api.nvim_create_user_command('AiTodo', function(opts)
  M.wrap_range(opts.line1, opts.line2)
end, {
  range = true,
  desc = 'Wrap lines in a commented ai-todo block',
})

return M
