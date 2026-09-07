--- Add, change, and delete surrounding pairs (`ys` / `cs` / `ds` and related).
--- Default nvim-surround setup; loads on VeryLazy.

return {
  'kylechui/nvim-surround',
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup {
      -- Configuration here, or leave empty to use defaults
    }
  end,
}
