return {
  'AckslD/nvim-neoclip.lua',
  dependencies = {
    { 'nvim-telescope/telescope.nvim' },
    { 'kkharji/sqlite.lua' },
  },
  config = function()
    require('neoclip').setup {
      enable_persistent_history = true,
    }

    vim.keymap.set('n', '"', require('telescope').extensions.neoclip.default, { desc = 'Registers' })
  end,
}
