--- Colorscheme catalog and the single theme actually installed at startup.
---
--- `color_schemes` lists available themes; `selected_theme` chooses which spec
--- lazy.nvim loads (`priority = 1000`). A theme uses `repo` (GitHub) or `dir`
--- (local path). Themes not selected are not installed.

---@class ColorSchemeName
---@field colorscheme string

---@class ConfigFunction
---@field configfunc fun(): nil

---@class ColorScheme
---@field repo? string
---@field dir? string
---@field name? string
---@field dependencies? string
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
  ['catppuccin-mocha'] = {
    repo = 'catppuccin/nvim',
    config = { colorscheme = 'catppuccin-mocha' },
  },
  ['catppuccin-nvim'] = {
    repo = 'catppuccin/nvim',
    config = { colorscheme = 'catppuccin-nvim' },
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
  alabaster3 = { repo = 'mcncl/alabaster.nvim', config = { colorscheme = 'alabaster' } },
  alabaster_dark = {
    dir = '/Users/vamsi/repo/alabaster-dark',
    name = 'alabaster-dark',
    config = { colorscheme = 'alabaster-dark' },
  },
  everforest = { repo = 'sainnhe/everforest', config = { colorscheme = 'everforest' } },
  github_light = {
    repo = 'projekt0n/github-nvim-theme',
    config = { colorscheme = 'github_light' },
  },
  gruvbox = { repo = 'ellisonleao/gruvbox.nvim', config = { colorscheme = 'gruvbox' } },
  koda = { repo = 'oskarnurm/koda.nvim', config = { colorscheme = 'koda' } },
  nofrils = { repo = 'robertmeta/nofrils', config = { colorscheme = 'nofrils-acme' } },
  ['nofrils-dark'] = {
    repo = 'robertmeta/nofrils',
    config = { colorscheme = 'nofrils-dark' },
  },
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
  modus = {
    repo = 'miikanissi/modus-themes.nvim',
    config = {
      configfunc = function()
        ---@diagnostic disable-next-line: missing-fields
        require('modus-themes').setup {
          variants = {
            -- modus_operandi = 'tinted',
          },
        }
        vim.cmd.colorscheme(
          vim.o.background == 'dark' and 'modus_vivendi' or 'modus_operandi'
        )
      end,
    },
  },
  bones = {
    repo = 'zenbones-theme/zenbones.nvim',
    dependencies = 'rktjmp/lush.nvim',
    config = { colorscheme = 'neobones' },
  },
  hybrid = {
    repo = 'w0ng/vim-hybrid',
    config = { colorscheme = 'hybrid' },
  },
}

-- local selected_theme = 'catppuccin-nvim'
-- local selected_theme = 'nofrils-dark'
-- local selected_theme = 'alabaster3'
-- local selected_theme = 'vscode'
-- local selected_theme = 'bones'
local selected_theme = 'alabaster_dark'

--[[ -- Fix UI issues
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { bold = true })
    vim.api.nvim_set_hl(0, 'DiagnosticFloatingHint', { link = 'DiagnosticFloatingInfo' })
    vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { foreground = 'darkgreen' })
    vim.api.nvim_set_hl(0, 'MatchParen', { bold = true, fg = 'black', underline = true })
  end,
}) ]]

-- vim.cmd.colorscheme 'habamax'

local theme = color_schemes[selected_theme]
local spec = {
  dir = theme.dir,
  name = theme.name,
  lazy = false,
  -- enabled = false,
  dependencies = theme.dependencies,
  priority = 1000,
  config = function()
    vim.o.termguicolors = true
    vim.o.background = 'dark'
    local config = theme.config
    if config.configfunc ~= nil then
      config.configfunc()
    else
      vim.cmd.colorscheme(config.colorscheme)
    end
  end,
}
if theme.repo then
  spec[1] = theme.repo
end
return spec
