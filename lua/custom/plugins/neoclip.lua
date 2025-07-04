return {
  'AckslD/nvim-neoclip.lua',
  dependencies = {
    { 'nvim-telescope/telescope.nvim' },
    { 'kkharji/sqlite.lua' },
  },
  config = function()
    require('neoclip').setup {
      history = 100,
      enable_persistent_history = true,
      db_path = '.neoclip.sqlite3',
    }

    vim.keymap.set('n', '"', require('telescope').extensions.neoclip.default, { desc = 'Registers' })
  end,
}
