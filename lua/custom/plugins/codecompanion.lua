return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
  },
  opts = {
    strategies = {
      chat = { adapter = { name = 'gemini', model = 'gemini-2.5-flash-lite' } },
      inline = { adapter = { name = 'gemini', model = 'gemini-2.5-flash-lite' } },
    },
    adapters = {
      gemini = function()
        return require('codecompanion.adapters').extend('gemini', {
          env = {
            api_key = function()
              return os.getenv 'GEMINI_API_KEY'
            end,
          },
        })
      end,
    },
    interactions = {
      chat = {
        adapter = {
          name = 'gemini',
          model = 'gemini-2.5-flash-lite',
        },
      },
    },
    display = {
      chat = {
        window = { layout = 'float' },
      },
    },
    extensions = {
      mcphub = {
        callback = 'mcphub.extensions.codecompanion',
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true,
        },
      },
    },
  },
}
