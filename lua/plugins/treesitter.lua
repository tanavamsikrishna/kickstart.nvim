return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    local needed_packages = {
      'css',
      'diff',
      'fish',
      'html',
      'javascript',
      'lua',
      'luadoc',
      'markdown',
      'nu',
      'python',
      'regex',
      'rust',
      'svelte',
      'zsh',
      'toml',
      'typescript',
      'vim',
      'vimdoc',
    }
    local treesitter = require 'nvim-treesitter'
    treesitter.install(needed_packages)
    vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    local svelte_augroup = vim.api.nvim_create_augroup('TreeSitterStart', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = svelte_augroup,
      pattern = needed_packages,
      callback = function() vim.treesitter.start() end,
    })
  end,
}
