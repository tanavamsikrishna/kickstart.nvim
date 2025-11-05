return {
  'nvim-neo-tree/neo-tree.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  opts = {
    sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
    window = { position = 'float' },
    default_source = 'last',
  },
  config = function(_, opts)
    require('neo-tree').setup(opts)
    vim.api.nvim_set_hl(0, 'NeoTreeTitleBar', { link = 'NeoTreeFileStatsHeader' })
  end,
}
