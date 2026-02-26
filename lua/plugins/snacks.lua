return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
          vim.api.nvim_set_hl(0, 'SnacksPickerMatch', {})
          vim.api.nvim_set_hl(0, 'SnacksPickerSearch', {})
        end,
      })
    end,
    ---@type snacks.Config
    opts = {
      quickfile = {},
      picker = {
        enabled = true,
        -- Define custom layouts
        layouts = {
          custom = {
            layout = {
              backdrop = false,
              width = 0.75,
              min_width = 50,
              max_width = 100,
              height = 0.75,
              min_height = 2,
              box = 'vertical',
              border = false,
              title = '{title}',
              title_pos = 'center',
              { win = 'input', height = 1, border = 'rounded' },
              { win = 'list', border = 'none' },
              { win = 'preview', title = '{preview}', height = 0.65, border = 'top' },
            },
          },
        },
        layout = {
          -- Cycle through custom layouts
          cycle = true,
          preset = 'custom',
        },
      },
    },
    keys = {
      { '<leader>sh', function() require('snacks').picker.help() end, desc = '[S]earch [H]elp' },
      {
        '<leader>sk',
        function() require('snacks').picker.keymaps() end,
        desc = '[S]earch [K]eymaps',
      },
      { '<leader>sf', function() require('snacks').picker.files() end, desc = '[S]earch [F]iles' },
      {
        '<leader>ss',
        function() require('snacks').picker.pickers() end,
        desc = '[S]earch [S]elect Picker',
      },
      {
        '<leader>sw',
        function() require('snacks').picker.grep_word() end,
        desc = '[S]earch current [W]ord',
      },
      { '<leader>sg', function() require('snacks').picker.grep() end, desc = '[S]earch by [G]rep' },
      {
        '<leader>sd',
        function() require('snacks').picker.diagnostics() end,
        desc = '[S]earch [D]iagnostics',
      },
      {
        '<leader>sr',
        function() require('snacks').picker.resume() end,
        desc = '[S]earch [R]esume',
      },
      {
        '<leader>s.',
        function() require('snacks').picker.recent() end,
        desc = '[S]earch Recent Files ("." for repeat)',
      },
      {
        '<leader>sc',
        function() require('snacks').picker.commands() end,
        desc = '[S]earch [C]ommands',
      },
      {
        '<leader><leader>',
        function() require('snacks').picker.buffers() end,
        desc = '[ ] Find existing buffers',
      },
      {
        '<leader>/',
        function() require('snacks').picker.lines() end,
        desc = '[/] Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        function() require('snacks').picker.grep { buffers = true } end,
        desc = '[S]earch [/] in Open Files',
      },
      {
        '<leader>sn',
        function() require('snacks').picker.files { cwd = vim.fn.stdpath 'config' } end,
        desc = '[S]earch [N]eovim files',
      },
    },
  },
}
