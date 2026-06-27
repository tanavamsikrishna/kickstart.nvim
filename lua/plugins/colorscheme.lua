---@class ColorSchemeName
---@field colorscheme string

---@class ConfigFunction
---@field configfunc fun(): nil

---@class ColorScheme
---@field repo string
---@field config ColorSchemeName | ConfigFunction

---@type table<string, ColorScheme>
local color_schemes = {
  ['catppuccin-latte'] = {
    repo = 'catppuccin/nvim',
    config = { colorscheme = 'catppuccin-latte' },
  },
  ['gruvbox-classic'] = {
    repo = 'morhetz/gruvbox',
    config = { colorscheme = 'gruvbox' },
  },
  alabaster1 = { repo = 'p00f/alabaster.nvim', config = { colorscheme = 'alabaster' } },
  alabaster2 = {
    repo = 'agudulin/vim-colors-alabaster',
    config = { colorscheme = 'alabaster' },
  },
  everforest = { repo = 'sainnhe/everforest', config = { colorscheme = 'everforest' } },
  github_light = {
    repo = 'projekt0n/github-nvim-theme',
    config = { colorscheme = 'github_light' },
  },
  gruvbox = { repo = 'ellisonleao/gruvbox.nvim', config = { colorscheme = 'gruvbox' } },
  koda = { repo = 'oskarnurm/koda.nvim', config = { colorscheme = 'koda' } },
  nofrils = { repo = 'robertmeta/nofrils', config = { colorscheme = 'nofrils-acme' } },
  selenized = { repo = 'calind/selenized.nvim', config = { colorscheme = 'selenized' } },
  solarized1 = {
    repo = 'altercation/vim-colors-solarized',
    config = { colorscheme = 'solarized' },
  },
  solarized2 = {
    repo = 'maxmx03/solarized.nvim',
    config = { colorscheme = 'solarized' },
  },
  vscode = { repo = 'Mofiqul/vscode.nvim', config = { colorscheme = 'vscode' } },
  xcodelight = {
    repo = 'lunacookies/vim-colors-xcode',
    config = { colorscheme = 'xcodelight' },
  },
  modus_light = {
    repo = 'miikanissi/modus-themes.nvim',
    config = {
      configfunc = function()
        ---@diagnostic disable-next-line: missing-fields
        require('modus-themes').setup {
          variants = {
            modus_operandi = 'tinted',
          },
        }
        vim.cmd.colorscheme 'modus_operandi'
      end,
    },
  },
}

local selected_theme = 'modus_light'

return {
  lazy = false,
  color_schemes[selected_theme].repo,
  priority = 1000,
  config = function()
    vim.o.background = 'light'
    local config = color_schemes[selected_theme].config
    if config.configfunc ~= nil then
      config.configfunc()
    else
      vim.cmd.colorscheme(config.colorscheme)
    end
  end,
}
