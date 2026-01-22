return {
  'lukas-reineke/indent-blankline.nvim',
  enabled = true,
  main = 'ibl',
  opts = {
    scope = { enabled = true, show_start = false, show_end = false },
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

    indent = {
      char = '│',
      highlight = { 'MyUniformIndentColor' },
    },
  },
  config = function(_, opts)
    local hooks = require 'ibl.hooks'
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'MyUniformIndentColor', { fg = 'grey80' })
    end)

    require('ibl').setup(opts)
  end,
}
