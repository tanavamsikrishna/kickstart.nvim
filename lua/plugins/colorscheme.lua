return { -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:lua Snacks.picker.colorschemes()`.

  -- ACTIVE COLORSCHEME
  'ellisonleao/gruvbox.nvim',

  -- ALTERNATIVE COLORSCHEME PLUGINS (Commented out)
  -- 'projekt0n/github-nvim-theme',
  -- 'oskarnurm/koda.nvim',
  -- 'Mofiqul/vscode.nvim',
  -- 'lunacookies/vim-colors-xcode',
  -- 'morhetz/gruvbox',
  -- 'robertmeta/nofrils',
  -- 'p00f/alabaster.nvim',
  -- 'altercation/vim-colors-solarized',
  -- 'catppuccin/nvim',
  -- 'calind/selenized.nvim',

  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    -- =========================================================================
    -- GRUVBOX CONFIGURATION (Active)
    -- =========================================================================
    vim.o.background = 'light'

    require('gruvbox').setup {
      palette_overrides = {
        light0 = '#f5f5dc',
        light1 = '#ebebd0',
        light2 = '#e1e1c4',
        light3 = '#d7d7b8',
        light4 = '#cdcdac',
        dark0 = '#0f0f0f',
        dark1 = '#1a1a1a',
        dark2 = '#333333',
        dark3 = '#4d4d4d',
        dark4 = '#666666',
        gray = '#777777',
        faded_red = '#a80000',
        faded_green = '#286a28',
        faded_yellow = '#805000',
        faded_blue = '#004a8a',
        faded_purple = '#702a70',
        faded_aqua = '#1a6a6a',
        faded_orange = '#9a3a00',
      },
      overrides = {
        Search = { bg = '#e1e1c4', fg = '#1a1a1a', reverse = false },
        IncSearch = { bg = '#eec584', fg = '#0f0f0f', reverse = false },
        CurSearch = { bg = '#eec584', fg = '#0f0f0f', bold = true, reverse = false },
        Visual = { bg = '#d7d7b8', reverse = false },
        SignColumn = { bg = '#f5f5dc' },
        FoldColumn = { bg = '#f5f5dc' },
        CursorLine = { bg = '#ebebd0' },
        CursorLineNr = { fg = '#9a3a00', bg = '#ebebd0', bold = true },
        LineNr = { fg = '#a0a095' },
        WinSeparator = { fg = '#cdcdac' },
        StatusLine = { bg = '#ebebd0', fg = '#1a1a1a' },
        StatusLineNC = { bg = '#f5f5dc', fg = '#777777' },
        FloatBorder = { fg = '#cdcdac', bg = '#f5f5dc' },
        NormalFloat = { bg = '#f5f5dc' },
        Pmenu = { bg = '#ebebd0', fg = '#1a1a1a' },
        PmenuSel = { bg = '#d7d7b8', fg = '#0f0f0f', bold = true },
        KickstartLspReference = {
          bg = '#f3ddb1',
          fg = '#1a1a1a',
          underline = true,
          reverse = false,
        },
        IlluminatedWordText = { link = 'KickstartLspReference' },
        IlluminatedWordRead = { link = 'KickstartLspReference' },
        IlluminatedWordWrite = {
          bg = '#efc98f',
          fg = '#1a1a1a',
          bold = true,
          underline = true,
        },
        -- Optional legacy overrides:
        -- Visual = { link = 'Search' },
        -- NormalFloat = { link = 'Normal' },
        -- BlinkCmpGhostText = { link = 'Comment', italic = true },
        -- GruvBoxGreenBold = { fg = '#79740e' },
      },
    }
    vim.cmd.colorscheme 'gruvbox'

    -- =========================================================================
    -- ALTERNATIVE COLORSCHEME CONFIGS (Commented out)
    -- =========================================================================
    -- vim.cmd.colorscheme 'koda'
    -- vim.cmd.colorscheme 'github_light'
    -- vim.cmd.colorscheme 'vscode'
    -- vim.cmd.colorscheme 'xcodelight'
    -- vim.cmd.colorscheme 'solarized'
    -- vim.cmd.colorscheme 'catppuccin-latte'
    -- vim.cmd.colorscheme 'selenized'
    -- vim.api.nvim_set_hl(0, 'Identifier', { fg = '#53676d' })

    -- nofrils-acme:
    -- vim.cmd.colorscheme 'nofrils-acme'
    -- vim.api.nvim_set_hl(0, 'Comment', { fg = 'grey30', italic = true })

    -- alabaster:
    -- vim.cmd.colorscheme 'alabaster'
    -- vim.api.nvim_set_hl(0, 'Normal', { bg = '#FDF6E3' })
    -- vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#FDF6E3' })
    -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#FDF6E3' })
    -- vim.api.nvim_set_hl(0, 'FloatBorder', { bg = '#FDF6E3' })
  end,
}
