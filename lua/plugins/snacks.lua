local function get_picker_layout()
  local cols = vim.o.columns
  local lines = vim.o.lines

  -- 1. If too small, hide preview
  -- A width of < 100 is typically too cramped for a preview + list
  if cols < 100 then return 'vertical_no_preview' end

  -- 2. Landscape (Width > Height) -> Side by Side ('default' layout)
  -- We assume a char aspect ratio of ~1:2 (width:height)
  -- So physical width > physical height approximately implies cols * 1 > lines * 2
  if cols >= lines * 2.2 then return 'default' end

  -- 3. Portrait -> Up-Down ('vertical' layout)
  return 'vertical'
end

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
          vertical_no_preview = {
            layout = {
              backdrop = false,
              width = 0.5,
              min_width = 80,
              height = 0.8,
              min_height = 30,
              box = 'vertical',
              border = false,
              title = '{title} {live} {flags}',
              title_pos = 'center',
              { win = 'input', height = 1, border = 'bottom' },
              { win = 'list', border = 'none' },
            },
          },
        },
        layout = {
          -- Cycle through custom layouts
          cycle = true,
          preset = get_picker_layout(),
        },
      },
    },
    keys = {
      { '<leader>sh', function() require('snacks').picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() require('snacks').picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sf', function() require('snacks').picker.files() end, desc = '[S]earch [F]iles' },
      { '<leader>ss', function() require('snacks').picker.pickers() end, desc = '[S]earch [S]elect Picker' },
      { '<leader>sw', function() require('snacks').picker.grep_word() end, desc = '[S]earch current [W]ord' },
      { '<leader>sg', function() require('snacks').picker.grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() require('snacks').picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() require('snacks').picker.resume() end, desc = '[S]earch [R]esume' },
      {
        '<leader>s.',
        function() require('snacks').picker.recent() end,
        desc = '[S]earch Recent Files ("." for repeat)',
      },
      { '<leader>sc', function() require('snacks').picker.commands() end, desc = '[S]earch [C]ommands' },
      { '<leader><leader>', function() require('snacks').picker.buffers() end, desc = '[ ] Find existing buffers' },
      { '<leader>/', function() require('snacks').picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
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
