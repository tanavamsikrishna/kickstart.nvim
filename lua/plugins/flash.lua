--- Label-based jump and Treesitter selection (flash.nvim).
---
--- `F` jumps (`n`, `x`, `o`). `<leader>v` selects a syntax node.
--- Char-mode stays on for `f`, `t`, `T`, `;`, `,` and must not bind `F`.

---@type Flash.Config
local config_options = {
  modes = {
    char = {
      -- Default list is f,F,t,T,;, and array merge is by index, so this
      -- has to overwrite the `F` slot or char-mode keeps the backward find.
      keys = { 'f', 't', 'T', ';', ',' },
    },
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
