return {
  'chrisgrieser/nvim-rip-substitute',
  enabled = false,
  cmd = 'RipSubstitute',
  opts = {},
  keys = {
    {
      '<leader>rr',
      function() require('rip-substitute').sub() end,
      mode = { 'n', 'x' },
      desc = ' rip substitute',
    },
  },
}
