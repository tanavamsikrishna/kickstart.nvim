local model_to_use = 'gemini-flash-latest'

return {
  'olimorris/codecompanion.nvim',
  enabled = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  keys = function()
    local code_companion = require 'codecompanion'
    return {
      { '<leader>a', function() code_companion.toggle() end, desc = 'CodeCompanion: Toggle' },
    }
  end,
  opts = {
    interactions = {
      chat = { adapter = 'gemini_cli' },
      agent = { adapter = 'gemini_cli' },
    },
    display = {
      chat = {
        window = { layout = 'float' },
      },
    },
  },
}
