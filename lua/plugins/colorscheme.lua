--- Colorscheme catalog and the single theme actually installed at startup.
---
--- `color_schemes` lists available repos; `selected_theme` chooses which spec
--- lazy.nvim loads (`priority = 1000`). Currently `tokyonight` with a dark
--- background. Themes not selected are not installed.

---@class ColorSchemeName
---@field colorscheme string

---@class ConfigFunction
---@field configfunc fun(): nil

---@class ColorScheme
---@field repo string
---@field config ColorSchemeName | ConfigFunction

---@type table<string, ColorScheme>
local color_schemes = {
  ['tokyonight'] = {
    repo = 'folke/tokyonight.nvim',
    config = { colorscheme = 'tokyonight-night' },
  },
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
            -- modus_operandi = 'tinted',
          },
        }
        vim.cmd.colorscheme 'modus_operandi'
      end,
    },
  },
}

local selected_theme = 'tokyonight'

--[[ -- Fix UI issues
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { bold = true })
    vim.api.nvim_set_hl(0, 'DiagnosticFloatingHint', { link = 'DiagnosticFloatingInfo' })
    vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { foreground = 'darkgreen' })
    vim.api.nvim_set_hl(0, 'MatchParen', { bold = true, fg = 'black', underline = true })
  end,
}) ]]

return {
  lazy = false,
  color_schemes[selected_theme].repo,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    local config = color_schemes[selected_theme].config
    if config.configfunc ~= nil then
      config.configfunc()
    else
      vim.cmd.colorscheme(config.colorscheme)
    end
  end,
}
