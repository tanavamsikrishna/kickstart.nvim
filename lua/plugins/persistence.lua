return {
  {
    'folke/persistence.nvim',
    enabled = false,
    opts = {
      need = 0,
      branch = true,
    },
    config = function(_, opts)
      require('persistence').setup(opts)

      -- Keymap
      vim.keymap.set('n', '<leader>ps', function() require('persistence').load() end, { desc = 'Load the session for the current directory' })
      vim.keymap.set('n', '<leader>pS', function() require('persistence').select() end, { desc = 'Select a session to load' })
      vim.keymap.set('n', '<leader>pl', function() require('persistence').load { last = true } end, { desc = 'Load the last session' })
      vim.keymap.set('n', '<leader>pd', function() require('persistence').stop() end, { desc = "Stop Persistence => session won't be saved on exit" })
    end,
  },
}
