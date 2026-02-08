local model_to_use = 'gemini-flash-latest'

return {
  'olimorris/codecompanion.nvim',
  enabled = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
  },
  opts = {
    -- strategies = {
    --   chat = { adapter = { name = 'gemini_cli' } },
    --   inline = { adapter = { name = 'gemini_cli' } },
    -- },
    interactions = {
      chat = {
        adapter = { name = 'gemini_cli' },
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
