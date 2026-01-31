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

    treesitter.setup { indent = { enable = true } }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { '<filetype>' },
      callback = vim.treesitter.start,
    })

    vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
}
