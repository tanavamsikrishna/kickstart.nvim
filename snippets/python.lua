local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local r = require('luasnip.extras').rep

return {
  s('marimo', {
    t {
      'import marimo',
      '',
      '__generated_with = "0.0.0"',
      'app = marimo.App(width="medium")',
      '',
      'with app.setup:',
      '\timport marimo as mo',
      '',
      '',
      '@app.cell',
      'def _():',
      '\t',
    },
    i(1, '...'),
    t {
      '',
      '',
      'if __name__ == "__main__":',
      '\tapp.run()',
    },
  }),
}
