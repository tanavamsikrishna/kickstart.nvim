return {
  'cshuaimin/ssr.nvim',
  enabled = true,
  module = 'ssr',
  keys = {
    {
      '<leader>rs',
      function() require('ssr').open() end,
      mode = { 'n', 'x' },
      desc = 'Structural search/replace',
    },
  },
}
