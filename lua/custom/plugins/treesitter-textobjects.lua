return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  init = function()
    -- Disable entire built-in ftplugin mappings to avoid conflicts.
    -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
    vim.g.no_plugin_maps = true
    require('nvim-treesitter-textobjects').setup {
      move = {
        set_jumps = true,
      },
    }

    local move = require 'nvim-treesitter-textobjects.move'

    vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() move.goto_next_end('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() move.goto_previous_end('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '}', function() move.goto_next_start('@statement.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '{', function() move.goto_previous_start('@statement.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']s', function() move.goto_next_start('@local.scope', 'locals') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[s', function() move.goto_previous_start('@local.scope', 'locals') end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '][', function() move.goto_next_end('@class.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() move.goto_previous_end('@class.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']d', function() move.goto_next('@conditional.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[d', function() move.goto_previous('@conditional.outer', 'textobjects') end)
  end,
}
