--- LSP progress UI and `vim.notify` replacement (fidget.nvim).
--- Notification window avoids Snacks picker/explorer floats; border is omitted
--- under Neovide.

local opts = {
  notification = {
    override_vim_notify = true,
    window = {
      avoid = {
        'snacks_picker_list',
        'snacks_picker_input',
        'snacks_layout_box',
      },
      border = vim.g.neovide and 'none' or 'rounded',
    },
  },
}

return {
  'j-hui/fidget.nvim',
  opts = opts,
}
