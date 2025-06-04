return {
  'nvim-neo-tree/neo-tree.nvim',
  opts = {
    sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
    window = { position = 'float' },
    default_source = 'last',
  },
}
