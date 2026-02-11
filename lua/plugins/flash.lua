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
    vim.api.nvim_set_hl(0, 'FlashLabel', { bg = '#b16286', fg = '#fbf1c7', bold = true })
  end,
}
