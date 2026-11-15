--- Label-based jump and Treesitter selection (flash.nvim).
---
--- `F` jumps. `<leader>v` selects a syntax node. Char-mode keeps
--- `t`/`T`/`;`/`,`; `f` is the picker prefix. See `keybindings.md`.

---@type Flash.Config
local config_options = {
  modes = {
    treesitter = {
      label = { style = 'overlay' },
    },
  },
  -- After tbl_deep_extend a shorter list keeps leftover `f`/`F` slots, and
  -- flash maps those again. Replace the list here, before char setup.
  config = function(opts)
    opts.modes.char.keys = { 't', 'T', ';', ',' }
  end,
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
      'F',
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
