local opts = {
  notification = {
    override_vim_notify = true,
    window = { avoid = { 'NvimTree' } },
  },
}

return {
  'j-hui/fidget.nvim',
  opts = opts,
}
