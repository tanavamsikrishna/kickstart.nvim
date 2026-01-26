local model_to_use = 'gemini-flash-latest'

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
  },
  opts = {
    strategies = {
      chat = { adapter = { name = 'gemini', model = model_to_use } },
      inline = { adapter = { name = 'gemini', model = model_to_use } },
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
          model = model_to_use,
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
          make_slash_commands = true,
          make_tools = true,
          make_vars = true,
          show_result_in_chat = true,
          show_server_tools_in_chat = true,
        },
      },
    },
  },
}
