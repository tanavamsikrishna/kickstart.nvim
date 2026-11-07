--- Snippets available in every filetype.
---
--- `ai-todo` wraps the marker in a comment. `comments_by_filetype` holds the
--- syntax for the languages used here: a block comment when the language has
--- one, otherwise a line comment. Every other filetype uses the buffer line comment.

local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local util = require 'luasnip.util.util'

--- Filetype to comment delimiters.
--- A string is a line comment. A pair wraps the marker in a block comment.
--- Markdown and Svelte use HTML comments.
local comments_by_filetype = {
  lua = { '--[[', ']]' },
  markdown = { '<!--', '-->' },
  nim = { '#[', ']#' },
  nu = '#',
  python = '#',
  rust = { '/*', '*/' },
  svelte = { '<!--', '-->' },
  toml = '#',
  typescript = { '/*', '*/' },
}

--- Left delimiter, and the closing delimiter for block comments.
--- The closer is empty for a line comment.
---@return string left
---@return string right
local function comment_markers()
  local spec = comments_by_filetype[vim.bo.filetype]
  if type(spec) == 'string' then return spec, '' end
  if type(spec) == 'table' then return spec[1], spec[2] end
  return util.buffer_comment_chars()[1], ''
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
