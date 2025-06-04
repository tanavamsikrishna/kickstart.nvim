return {
  'folke/flash.nvim',
  event = 'VimEnter',
  opts = {
    label = { uppercase = false },
  },
  keys = {
    {
      '<leader>fs',
      function()
        require('flash').treesitter()
      end,
      mode = 'n',
      desc = 'Select based on syntax',
    },
    {
      '<leader>fj',
      function()
        require('flash').jump()
      end,
      mode = 'n',
      desc = 'Jump to location',
    },
  },
}
