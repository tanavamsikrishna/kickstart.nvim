--- Snippets available in every filetype.
---
--- `ai-todo` wraps the marker in a comment. Delimiters come from Comment.nvim
--- via `config.comment_utils`: a block comment when the language has one,
--- otherwise the line comment. `:AiTodo` comments a line range the same way.

local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

--- Left delimiter, and the closing delimiter for block comments.
--- The closer is empty for a line comment.
---@return string left
---@return string right
local function comment_markers()
  local line = vim.fn.line '.'
  return require('config.comment_utils').comment_delimiters(line, line)
end

return {
  s('ai-todo', {
    f(function()
      local left = comment_markers()
      return left
    end),
    -- The xml tag below has been split so that parsers searching for todos
    -- do not think that it is actually a todo task
    t(' <' .. 'ai-todo> '),
    i(1, '...'),
    t(' <' .. '/ai-todo>'),
    f(function()
      local _, right = comment_markers()
      if right == '' then return '' end
      return ' ' .. right
    end),
  }),
}
