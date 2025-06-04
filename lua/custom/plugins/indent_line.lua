return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {
    scope = { enabled = false },
    exclude = {
      filetypes = {
        'help',
        'alpha',
        'dashboard',
        'neo-tree',
        'Trouble',
        'trouble',
        'lazy',
        'mason',
        'notify',
        'toggleterm',
        'lazyterm',
      },
    },
  },
  config = function(_, _)
    local hooks = require 'ibl.hooks'
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'MyUniformIndentColor', { fg = '#e7eaf0' })
    end)

    require('ibl').setup {
      indent = {
        char = '▎',
        -- tab_char = '▎',
        highlight = { 'MyUniformIndentColor' },
      },
      scope = { enabled = false },
    }
  end,
}
