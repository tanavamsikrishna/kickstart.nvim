local opts = {
  notification = {
    override_vim_notify = true,
    window = {
      avoid = { 'NvimTree' },
      border = vim.g.neovide and 'none' or 'rounded',
    },
  },
}

return {
  'j-hui/fidget.nvim',
  opts = opts,
}
