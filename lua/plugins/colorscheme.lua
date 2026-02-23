return { -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:lua Snacks.picker.colorschemes()`.

  -- 'projekt0n/github-nvim-theme',
  -- 'oskarnurm/koda.nvim',
  -- 'Mofiqul/vscode.nvim',
  -- 'lunacookies/vim-colors-xcode',
  -- 'morhetz/gruvbox',
  'ellisonleao/gruvbox.nvim',
  -- 'robertmeta/nofrils',
  -- 'p00f/alabaster.nvim',
  -- 'altercation/vim-colors-solarized',
  -- 'catppuccin/nvim',
  -- 'calind/selenized.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    vim.o.background = 'light'
    -- vim.cmd.colorscheme 'koda'
    -- vim.cmd.colorscheme 'github_light'
    -- vim.cmd.colorscheme 'vscode'
    -- vim.cmd.colorscheme 'xcodelight'

    require('gruvbox').setup {}
    vim.cmd.colorscheme 'gruvbox'

    -- vim.cmd.colorscheme 'gruvbox'
    -- vim.api.nvim_set_hl(0, 'Visual', { link = 'Search' })
    -- vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' }) -- For floating windows
    -- vim.api.nvim_set_hl(0, 'BlinkCmpGhostText', { link = 'Comment', italic = true })
    -- vim.api.nvim_set_hl(0, 'GruvBoxGreenBold', { fg = '#79740e' })

    -- vim.cmd.colorscheme 'solarized'

    -- vim.cmd.colorscheme 'nofrils-acme'
    -- vim.api.nvim_set_hl(0, 'Comment', { fg = 'grey30', italic = true })

    -- vim.cmd.colorscheme 'alabaster'
    -- vim.api.nvim_set_hl(0, 'Normal', { bg = '#FDF6E3' })
    -- vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#FDF6E3' }) -- For inactive windows
    -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#FDF6E3' }) -- For floating windows
    -- vim.api.nvim_set_hl(0, 'FloatBorder', { bg = '#FDF6E3' })

    -- vim.cmd.colorscheme 'catppuccin-latte'
    -- vim.cmd.colorscheme 'selenized'
    -- vim.api.nvim_set_hl(0, 'Identifier', { fg = '#53676d' })
  end,
}
