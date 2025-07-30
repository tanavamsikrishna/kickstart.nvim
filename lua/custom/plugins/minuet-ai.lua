return {
  'milanglacier/minuet-ai.nvim',
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
          model = 'gemini-2.0-flash',
          stream = true,
          api_key = 'GEMINI_API_KEY',
          end_point = 'https://generativelanguage.googleapis.com/v1beta/models',
          optional = {
            generationConfig = {
              maxOutputTokens = 256,
              thinkingConfig = {
                thinkingBudget = 0,
              },
            },
          },
        },
        ollama_qwen = {
          api_key = 'TERM',
          name = 'Ollama',
          end_point = 'http://localhost:11434/v1/completions',
          model = 'qwen2.5-coder:7b',
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { '*' },
        auto_trigger_ignore_ft = { 'TelescopePrompt' },
        keymap = {
          -- accept whole completion
          accept = '<D-A>',
          -- accept one line
          accept_line = '<D-a>',
          -- accept n lines (prompts for number)
          -- e.g. "A-z 2 CR" will accept 2 lines
          accept_n_lines = '<D-z>',
          -- Cycle to prev completion item, or manually invoke completion
          prev = '<D-[>',
          -- Cycle to next completion item, or manually invoke completion
          next = '<D-]>',
          dismiss = '<D-e>',
        },
      },
    }
  end,
}
