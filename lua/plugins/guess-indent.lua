--- Detect a buffer's indent style (tabs vs spaces, width) from existing content.
--- Default setup; no keymaps.

return {
  'NMAC427/guess-indent.nvim',
  config = function() require('guess-indent').setup {} end,
}
