-- Mini.nvim: picker, floating file explorer, sessions, and next-key clues.
--
-- `\` toggles the explorer; `|` reveals the current file in it.
-- `<leader>n` clears active notifications (history is kept).
-- `f*` opens pickers; `/` and `?` remain Vim search. `fn` searches
-- under the Neovim config dir. Picker/explorer use Mini defaults
-- (fuzzy matching, default float window); only `trash` behaviour
-- from the previous explorer is kept (`permanent_delete = false`).
-- mini.clue triggers `g`, `m`, normal `f`, `[`/`]`, and `<leader>`.
-- `<localleader>` is not a trigger (`,` stays Flash char-mode). Group
-- labels are `<leader>h` and `<leader>t`; other rows come from keymap
-- `desc`. Starter clues for `z`, marks, registers, windows, and `<C-x>`
-- stay.

return {
  {
    'nvim-mini/mini.nvim',
    lazy = false,
    config = function()
      -- session management
      require('mini.sessions').setup { directory = '', autoread = true }
      -- icons for pickers (LSP symbols in mini.extra) and blink.cmp
      require('mini.icons').setup {}
      -- notifications
      require('mini.notify').setup {
        window = { max_width_share = 0.5, winblend = 0 },
      }
      -- picker; sets vim.ui.select and provides :Pick
      local MiniPick = require 'mini.pick'
      MiniPick.setup {
        window = {
          config = function()
            local height = math.floor(0.618 * vim.o.lines)
            local width = math.floor(0.8 * vim.o.columns)
            return {
              anchor = 'NW',
              height = height,
              width = width,
              row = math.floor(0.5 * (vim.o.lines - height)),
              col = math.floor(0.5 * (vim.o.columns - width)),
            }
          end,
        },
      }

      MiniPick.registry.buffers = function()
        local items, cwd = {}, vim.fn.getcwd()
        for _, buf_info in ipairs(vim.fn.getbufinfo()) do
          if buf_info.listed == 1 then
            local name = vim.fs.relpath(cwd, buf_info.name) or buf_info.name
            table.insert(
              items,
              { text = name, bufnr = buf_info.bufnr, _lastused = buf_info.lastused }
            )
          end
        end

        table.sort(items, function(a, b) return a._lastused > b._lastused end)

        local show = function(buf_id, items_to_show, query)
          MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
        end
        local opts = { source = { name = 'Buffers', items = items, show = show } }
        return MiniPick.start(opts)
      end

      -- extra pickers (keymaps, diagnostics, commands, oldfiles, LSP)
      require('mini.extra').setup {}
      -- file explorer; deletes go to the mini trash, not permanent
      require('mini.files').setup { options = { permanent_delete = false } }

      -- Configured prefixes, plus starter triggers that are not prefixes here.
      -- Do not trigger `<LocalLeader>`: `,` is Flash char-mode repeat.
      -- `f` is normal-only so visual/operator `f` stays find-char. `F` is a leaf.
      local miniclue = require 'mini.clue'
      miniclue.setup {
        triggers = {
          { mode = { 'n', 'x' }, keys = '<Leader>' },
          { mode = 'n', keys = 'f' },
          { mode = { 'n', 'x' }, keys = 'g' },
          { mode = { 'n', 'x' }, keys = 'm' },
          { mode = 'n', keys = '[' },
          { mode = 'n', keys = ']' },
          { mode = 'i', keys = '<C-x>' },
          { mode = { 'n', 'x' }, keys = "'" },
          { mode = { 'n', 'x' }, keys = '`' },
          { mode = { 'n', 'x' }, keys = '"' },
          { mode = { 'i', 'c' }, keys = '<C-r>' },
          { mode = 'n', keys = '<C-w>' },
          { mode = { 'n', 'x' }, keys = 'z' },
        },
        clues = {
          -- Groups have no mapping of their own. Leaves use keymap `desc`.
          { mode = { 'n', 'x' }, keys = '<Leader>h', desc = '+Git hunk' },
          { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
          miniclue.gen_clues.square_brackets(),
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
        window = { config = { width = 50, height = 20 } },
      }
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
        '<leader>n',
        function() require('mini.notify').clear() end,
        desc = 'Clear notifications',
      },
      {
        'fh',
        function() require('mini.pick').builtin.help() end,
        desc = 'Search Help',
      },
      {
        'fk',
        function() require('mini.extra').pickers.keymaps() end,
        desc = 'Search Keymaps',
      },
      {
        'fd',
        function() require('mini.extra').pickers.diagnostic() end,
        desc = 'Search Diagnostics',
      },
      {
        'fr',
        function() require('mini.pick').builtin.resume() end,
        desc = 'Search Resume',
      },
      {
        'f.',
        function() require('mini.extra').pickers.oldfiles() end,
        desc = 'Search Recent Files ("." for repeat)',
      },
      {
        'fc',
        function() require('mini.extra').pickers.commands() end,
        desc = 'Search Commands',
      },
      {
        'fb',
        function() require('mini.pick').registry.buffers() end,
        desc = 'Find existing buffers',
      },
      {
        'fn',
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
