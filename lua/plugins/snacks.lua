--- Snacks.nvim: fuzzy picker, floating file explorer, and LSP word references.
---
--- `/*` opens pickers; `//` is Vim in-buffer search (`/` is a prefix). `\`
--- toggles a centered 50%×80% explorer float; `|` reveals the current file.
--- `<C-Tab>` opens the buffer picker.
--- `]r`/`[r` jump among LSP references (auto-highlight in normal mode).
--- `/n` follows symlinks under the Neovim config dir. `<A-y>` in the picker
--- copies the selected path relative to cwd. Matcher is non-fuzzy with
--- smart-case.

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      quickfile = {},
      explorer = { replace_netrw = true, trash = true },
      words = { debounce = 200, modes = { 'n' } },
      picker = {
        matcher = {
          fuzzy = false,
          ignore_case = true,
          smart_case = true,
          frecency = true,
        },
        enabled = true,
        -- Define custom layouts
        layouts = {
          custom = {
            layout = {
              backdrop = false,
              min_width = 50,
              max_width = 90,
              height = 0.75,
              min_height = 2,
              box = 'vertical',
              border = 'rounded',
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
        sources = {
          explorer = {
            hidden = false,
            exclude = { '__marimo__', '__pycache__', '*.egg-info' },
            git_status = true,
            auto_close = true,
            -- Nested box with children skips the sidebar/custom presets.
            -- `position = 'float'` keeps this an overlay, not a split.
            layout = {
              hidden = { 'preview' },
              layout = {
                backdrop = false,
                position = 'float',
                width = 0.5,
                height = 0.8,
                box = 'vertical',
                border = 'rounded',
                title = '{title} {live} {flags}',
                title_pos = 'center',
                { win = 'input', height = 1, border = 'bottom' },
                { win = 'list', border = 'none' },
              },
            },
            formatters = { file = { git_status_hl = true } },
            icons = {
              git = { enabled = false },
              files = { dir = '', dir_open = '' },
            },
          },
        },

        -- 1. Create a global picker action to yank paths
        actions = {
          copy_path = function(picker, item)
            picker:close() -- Closes the picker UI
            if item and item.file then
              -- Get the path relative to your current working directory
              local path = vim.fn.fnamemodify(item.file, ':.')

              -- Set the path to the system clipboard register
              vim.fn.setreg('+', path)
              vim.notify(
                'Copied path: ' .. path,
                vim.log.levels.INFO,
                { title = 'Snacks Picker' }
              )
            end
          end,
        },

        -- 2. Bind the action to a keyboard shortcut
        win = {
          input = {
            keys = {
              -- Press Alt + Y (or change to your preferred key) in the picker to copy path
              ['<A-y>'] = { 'copy_path', mode = { 'i', 'n' } },
            },
          },
        },
      },
    },
    keys = {
      {
        '\\',
        function() require('snacks').explorer() end,
        desc = 'Explorer toggle',
      },
      {
        '|',
        function() require('snacks').explorer.reveal() end,
        desc = 'Explorer current file reveal',
      },
      {
        ']r',
        function() require('snacks').words.jump(vim.v.count1, true) end,
        desc = 'Next reference',
      },
      {
        '[r',
        function() require('snacks').words.jump(-vim.v.count1, true) end,
        desc = 'Previous reference',
      },
      {
        '//',
        '/',
        mode = { 'n', 'x' },
        desc = 'Search in buffer',
      },
      {
        '/h',
        function() require('snacks').picker.help() end,
        desc = 'Search Help',
      },
      {
        '/k',
        function() require('snacks').picker.keymaps() end,
        desc = 'Search Keymaps',
      },
      {
        '/f',
        function() require('snacks').picker.files { hidden = true } end,
        desc = 'Search for Files',
      },
      {
        '/s',
        function() require('snacks').picker.pickers() end,
        desc = 'Search Select Picker',
      },
      {
        '/w',
        function() require('snacks').picker.grep_word() end,
        desc = 'Search current Word',
      },
      {
        '/g',
        function() require('snacks').picker.grep() end,
        desc = 'Search by Grep',
      },
      {
        '/d',
        function() require('snacks').picker.diagnostics() end,
        desc = 'Search Diagnostics',
      },
      {
        '/r',
        function() require('snacks').picker.resume() end,
        desc = 'Search Resume',
      },
      {
        '/.',
        function() require('snacks').picker.recent() end,
        desc = 'Search Recent Files ("." for repeat)',
      },
      {
        '/c',
        function() require('snacks').picker.commands() end,
        desc = 'Search Commands',
      },
      {
        '<leader><leader>',
        function() require('snacks').picker.buffers() end,
        mode = { 'n', 'i' },
        desc = 'Find existing buffers',
      },
      {
        '<C-Tab>',
        function() require('snacks').picker.buffers() end,
        mode = { 'n', 'i' },
        desc = 'Find existing buffers',
      },
      {
        '<leader>/',
        function() require('snacks').picker.lines() end,
        desc = '/ Fuzzily search in current buffer',
      },
      {
        '/n',
        function()
          require('snacks').picker.files {
            cwd = vim.fn.stdpath 'config',
            follow = true,
          }
        end,
        desc = 'Search Neovim files',
      },
    },
  },
}
