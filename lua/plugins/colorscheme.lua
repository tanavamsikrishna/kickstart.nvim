---@type table<string, { repo: string, colorscheme: string, setup: fun():nil}>
local color_schemes = {
  ['catppuccin-latte'] = { repo = 'catppuccin/nvim', colorscheme = 'catppuccin-latte' },
  ['gruvbox-classic'] = { repo = 'morhetz/gruvbox', colorscheme = 'gruvbox' },
  alabaster1 = { repo = 'p00f/alabaster.nvim', colorscheme = 'alabaster' },
  alabaster2 = { repo = 'agudulin/vim-colors-alabaster', colorscheme = 'alabaster' },
  everforest = { repo = 'sainnhe/everforest', colorscheme = 'everforest' },
  github_light = { repo = 'projekt0n/github-nvim-theme', colorscheme = 'github_light' },
  gruvbox = { repo = 'ellisonleao/gruvbox.nvim', colorscheme = 'gruvbox' },
  koda = { repo = 'oskarnurm/koda.nvim', colorscheme = 'koda' },
  nofrils = { repo = 'robertmeta/nofrils', colorscheme = 'nofrils-acme' },
  selenized = { repo = 'calind/selenized.nvim', colorscheme = 'selenized' },
  solarized1 = { repo = 'altercation/vim-colors-solarized', colorscheme = 'solarized' },
  solarized2 = { repo = 'maxmx03/solarized.nvim', colorscheme = 'solarized' },
  vscode = { repo = 'Mofiqul/vscode.nvim', colorscheme = 'vscode' },
  xcodelight = { repo = 'lunacookies/vim-colors-xcode', colorscheme = 'xcodelight' },
  modus_light = {
    repo = 'miikanissi/modus-themes.nvim',
    colorscheme = 'modus_operandi',
    setup = function()
      vim.api.nvim_set_hl(0, 'IlluminatedWordText', { link = 'Search' })
      vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'Search' })
      vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'Search' })
    end,
  },
}

local selected_theme = 'modus_light'

return {
  lazy = false,
  color_schemes[selected_theme].repo,
  priority = 1000,
  config = function()
    vim.o.background = 'light'
    vim.cmd.colorscheme(color_schemes[selected_theme].colorscheme)
    local setup = color_schemes[selected_theme].setup
    if setup then setup() end
  end,
}
