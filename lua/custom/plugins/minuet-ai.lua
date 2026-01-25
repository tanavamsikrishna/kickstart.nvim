return {
  'milanglacier/minuet-ai.nvim',
  enabled = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('minuet').setup {
      provider = 'gemini',
      n_completions = 1,
      context_window = 2048,
      provider_options = {
        gemini = {
          model = 'gemini-2.5-flash-lite',
          stream = true,
          api_key = 'GEMINI_API_KEY',
          end_point = 'https://generativelanguage.googleapis.com/v1beta/models',
          optional = {
            generationConfig = {
              maxOutputTokens = 256,
            },
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = {},
        keymap = {
          -- accept whole completion
          accept = '<A-A>',
          -- accept one line
          accept_line = '<A-a>',
          -- accept n lines (prompts for number)
          -- e.g. "A-z 2 CR" will accept 2 lines
          accept_n_lines = '<A-z>',
          -- Cycle to prev completion item, or manually invoke completion
          prev = '<A-[>',
          -- Cycle to next completion item, or manually invoke completion
          next = '<A-]>',
          dismiss = '<A-e>',
        },
      },
    }
  end,
}
