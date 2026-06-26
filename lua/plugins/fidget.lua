local opts = {
  notification = {
    override_vim_notify = true,
    window = { avoid = { 'NvimTree' }, winblend = 25 },
  },
}

return {
  'j-hui/fidget.nvim',
  opts = opts,
}
