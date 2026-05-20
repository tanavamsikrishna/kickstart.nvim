local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local util = require 'luasnip.util.util'

return {
  s('ai-todo', {
    f(function()
      local comments = util.buffer_comment_chars()
      return comments[1]
    end),
    t ' <ai-todo> ',
    i(1, '...'),
    t ' </ai-todo>',
  }),
}
