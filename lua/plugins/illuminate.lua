local function activate_manual_highlight()
  local illuminate = require 'illuminate'
  illuminate.unfreeze_buf()
  illuminate.resume_buf()
  -- Freeze after triggering refresh so highlights stay until explicit clear.
  illuminate.freeze_buf()
end

local function goto_reference(direction)
  local illuminate = require 'illuminate'
  if direction == 'next' then
    illuminate.goto_next_reference()
  else
    illuminate.goto_prev_reference()
  end
  -- Keep highlight state frozen after navigation jumps.
  illuminate.freeze_buf()
end

local function clear_manual_highlight()
  local illuminate = require 'illuminate'
  illuminate.unfreeze_buf()
  illuminate.pause_buf()
end

return {
  'RRethy/vim-illuminate',
  opts = {
    disable_keymaps = true,
  },
  keys = {
    {
      ']r',
      function() goto_reference 'next' end,
      desc = 'Next reference',
    },
    {
      '[r',
      function() goto_reference 'prev' end,
      desc = 'Previous reference',
    },
    {
      'grh',
      activate_manual_highlight,
      desc = 'Highlight references',
    },
  },
  config = function(_, opts)
    local illuminate = require 'illuminate'
    local keymap_utils = require 'config.keymap_utils'
    illuminate.configure(opts)
    local run_previous_esc = keymap_utils.capture_map_runner('<Esc>', 'n')

    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup(
        'kickstart-illuminate-paused-by-default',
        { clear = true }
      ),
      callback = function(args)
        vim.api.nvim_buf_call(args.buf, function()
          illuminate.unfreeze_buf()
          illuminate.pause_buf()
        end)
      end,
    })

    -- Start paused in current buffer.
    illuminate.unfreeze_buf()
    illuminate.pause_buf()

    -- Explicit clear, similar to '*' + hlsearch semantics.
    vim.keymap.set('n', '<Esc>', function()
      clear_manual_highlight()
      run_previous_esc()
    end, { desc = 'Clear references, then run existing <Esc>' })
  end,
}
