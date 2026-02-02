return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  init = function()
    -- disable entire built-in ftplugin mappings to avoid conflicts.
    -- see https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
    vim.g.no_plugin_maps = true
    require('nvim-treesitter-textobjects').setup {
      move = {
        set_jumps = true,
      },
    }

    local move = require 'nvim-treesitter-textobjects.move'

    ---@param ts_exprs string|string[] the treesitter expression
    ---@param key_dynamic_part '['|'{' the part which will be "mirrored" to move the other direction
    ---@param key_static_part string|nil the identifier for this motion
    ---@param to_start boolean where to jump to start (or end) of the tag
    local function set_keymaps(ts_exprs, key_dynamic_part, key_static_part, to_start)
      key_static_part = key_static_part or ''
      local dynamic_keys
      if key_dynamic_part == '[' then
        dynamic_keys = { '[', ']' }
      else
        dynamic_keys = { '{', '}' }
      end
      local functions = to_start and { move.goto_previous_start, move.goto_next_start }
        or { move.goto_previous_end, move.goto_next_end }

      for i = 1, #dynamic_keys do
        vim.keymap.set(
          { 'n', 'x', 'o' },
          dynamic_keys[i] .. key_static_part,
          function() (functions[i])(ts_exprs, 'textobjects') end
        )
      end
    end

    set_keymaps({
      '@parameter.inner',
      '@call.outer',
      '@assignment.outer',
      '@statement.outer',
      -- '@local.scope',
      -- '@block.outer',
    }, '[', '', true)
    set_keymaps({ '@function.outer', '@class.outer' }, '{', '{', true)
    set_keymaps({ '@function.outer', '@class.outer' }, '{', '}', false)
  end,
}
