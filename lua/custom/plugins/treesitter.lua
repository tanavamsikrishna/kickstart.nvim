return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false, -- Treesitter should load early
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    local treesitter = require 'nvim-treesitter'

    treesitter.install {
      'diff',
      'fish',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'nu',
      'python',
      'regex',
      'rust',
      'svelte',
      'toml',
      'vim',
      'vimdoc',
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { '<filetype>' },
      callback = function() vim.treesitter.start() end,
    })

    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'

    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
}
