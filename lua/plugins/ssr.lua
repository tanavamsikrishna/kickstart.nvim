--- Structural search/replace

return {
  'cshuaimin/ssr.nvim',
  enabled = false,
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
