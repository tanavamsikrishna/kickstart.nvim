--- Label-based jump and Treesitter selection (flash.nvim).
---
--- `<leader>f` is the which-key group (Flash). `<leader>fj` jump; `<leader>fs`
--- Treesitter node select. Treesitter labels use overlay style. Custom
--- `FlashLabel` highlight is set in config.

---@type Flash.Config
local config_options = {
  modes = {
    treesitter = {
      label = { style = 'overlay' },
    },
  },
}

return {
  'folke/flash.nvim',
  event = 'VimEnter',
  opts = config_options,
  keys = {
    {
      '<leader>fs',
      function() require('flash').treesitter() end,
      mode = 'n',
      desc = 'Select based on syntax',
    },
    {
      '<leader>fj',
      function() require('flash').jump() end,
      mode = 'n',
      desc = 'Jump to location',
    },
  },
  config = function(_, opts)
    require('flash').setup(opts)
    require('which-key').add { { '<leader>f', group = 'Flash' } }
    vim.api.nvim_set_hl(
      0,
      'FlashLabel',
      { bg = '#b16286', fg = '#fbf1c7', bold = true }
    )
  end,
}
