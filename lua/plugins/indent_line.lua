--- Vertical indent guides (indent-blankline / ibl).
--- Scope highlighting is off. Guides are hidden in UI filetypes (help, lazy,
--- mason, trouble, etc.). Character is `│`.

return {
  'lukas-reineke/indent-blankline.nvim',
  enabled = true,
  main = 'ibl',
  opts = {
    scope = { enabled = false, show_start = false, show_end = false },
    exclude = {
      filetypes = {
        'help',
        'alpha',
        'dashboard',
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
      -- highlight = { 'MyUniformIndentColor' },
    },
  },
  config = function(_, opts)
    local hooks = require 'ibl.hooks'
    hooks.register(
      hooks.type.HIGHLIGHT_SETUP,
      function() vim.api.nvim_set_hl(0, 'MyUniformIndentColor', { fg = 'grey80' }) end
    )

    require('ibl').setup(opts)
  end,
}
