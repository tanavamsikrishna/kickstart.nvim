return {
  'kosayoda/nvim-lightbulb',
  opts = {
    autocmd = { enabled = true },
    virtual_text = { enabled = true },
    sign = { enabled = false },
  },
  config = function(_, opts)
    require('nvim-lightbulb').setup(opts)
  end,
}

