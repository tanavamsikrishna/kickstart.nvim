--- Label-based jump and Treesitter selection (flash.nvim).
---
--- `gj` jumps (go-to). `<leader>v` selects a syntax node (visual). Treesitter
--- labels use overlay style. Custom `FlashLabel` highlight is set in config.
--- See `keybindings.md`.

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
      '<leader>v',
      function() require('flash').treesitter() end,
      mode = { 'n', 'x' },
      desc = 'Select syntax node',
    },
    {
      'gj',
      function() require('flash').jump() end,
      mode = { 'n', 'x', 'o' },
      desc = 'Jump to location',
    },
  },
  config = function(_, opts)
    require('flash').setup(opts)
    vim.api.nvim_set_hl(
      0,
      'FlashLabel',
      { bg = '#b16286', fg = '#fbf1c7', bold = true }
    )
  end,
}
