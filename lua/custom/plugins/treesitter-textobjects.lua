return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  enable = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('nvim-treesitter.configs').setup {
      textobjects = {
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ['}'] = {
              query = { '@statement.outer', '@function.outer', '@class.outer' },
              desc = 'Next function or class start',
            },
            [']m'] = '@function.outer',
            [']]'] = { query = '@class.outer', desc = 'Next class start' },
            [']s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next scope' },
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['{'] = {
              query = { '@statement.outer', '@function.outer', '@class.outer' },
              desc = 'Next function or class start',
            },
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
            ['[s'] = { query = '@local.scope', query_group = 'locals', desc = 'Prev scope' },
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
      },
    }
  end,
}
