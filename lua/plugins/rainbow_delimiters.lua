--- Nested delimiter highlights via rainbow-delimiters.nvim.
---
--- Uses ordinal groups `RainbowDelimiter1`–`5` from the colorscheme
--- (alabaster-dark). Hues live in the theme, not here.

return {
  'HiPhish/rainbow-delimiters.nvim',
  config = function()
    require('rainbow-delimiters.setup').setup {
      highlight = {
        'RainbowDelimiter1',
        'RainbowDelimiter2',
        'RainbowDelimiter3',
        'RainbowDelimiter4',
        'RainbowDelimiter5',
      },
    }
  end,
}
