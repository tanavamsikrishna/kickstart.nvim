-- Mini.nvim: picker (`j*` = jump with picker), floating file explorer,
-- and session management.
--
-- `\` toggles the explorer; `|` reveals the current file in it.
-- `j*` opens pickers; `/` and `?` remain Vim search. `jn` searches
-- under the Neovim config dir. Picker/explorer use Mini defaults
-- (fuzzy matching, default float window); only `trash` behaviour
-- from the previous explorer is kept (`permanent_delete = false`).

return {
  {
    'nvim-mini/mini.nvim',
    lazy = false,
    config = function()
      -- session management
      require('mini.sessions').setup { directory = '', autoread = true }
      -- icons for pickers (LSP symbols in mini.extra) and blink.cmp
      require('mini.icons').setup {}
      -- picker; sets vim.ui.select and provides :Pick
      require('mini.pick').setup {}
      -- extra pickers (keymaps, diagnostics, commands, oldfiles, LSP)
      require('mini.extra').setup {}
      -- file explorer; deletes go to the mini trash, not permanent
      require('mini.files').setup { options = { permanent_delete = false } }
    end,
    keys = {
      {
        '\\',
        function()
          local files = require 'mini.files'
          if files.close() == nil then files.open() end
        end,
        desc = 'Explorer toggle',
      },
      {
        '|',
        function()
          local path = vim.api.nvim_buf_get_name(0)
          require('mini.files').open(path ~= '' and path or nil)
        end,
        desc = 'Explorer current file reveal',
      },
      {
        'jh',
        function() require('mini.pick').builtin.help() end,
        desc = 'Search Help',
      },
      {
        'jk',
        function() require('mini.extra').pickers.keymaps() end,
        desc = 'Search Keymaps',
      },
      {
        'jf',
        function() require('mini.pick').builtin.files() end,
        desc = 'Search for Files',
      },
      {
        'jw',
        function()
          require('mini.pick').builtin.grep { pattern = vim.fn.expand '<cword>' }
        end,
        desc = 'Search current Word',
      },
      {
        'jg',
        function() require('mini.pick').builtin.grep() end,
        desc = 'Search by Grep',
      },
      {
        'jd',
        function() require('mini.extra').pickers.diagnostic() end,
        desc = 'Search Diagnostics',
      },
      {
        'jr',
        function() require('mini.pick').builtin.resume() end,
        desc = 'Search Resume',
      },
      {
        'j.',
        function() require('mini.extra').pickers.oldfiles() end,
        desc = 'Search Recent Files ("." for repeat)',
      },
      {
        'jc',
        function() require('mini.extra').pickers.commands() end,
        desc = 'Search Commands',
      },
      {
        'jb',
        function() require('mini.pick').builtin.buffers() end,
        desc = 'Find existing buffers',
      },
      {
        'jn',
        function()
          require('mini.pick').builtin.files(
            nil,
            { source = { cwd = vim.fn.stdpath 'config' } }
          )
        end,
        desc = 'Search Neovim files',
      },
    },
  },
}
