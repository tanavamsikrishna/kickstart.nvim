--- search replace with ripgrep

return {
  'chrisgrieser/nvim-rip-substitute',
  enabled = false,
  cmd = 'RipSubstitute',
  opts = {},
  keys = {
    {
      '<leader>rs',
      function() require('rip-substitute').sub() end,
      mode = { 'n', 'x' },
      desc = ' rip substitute',
    },
  },
}
