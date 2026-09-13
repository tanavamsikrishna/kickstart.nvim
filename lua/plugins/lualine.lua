-- Define a function that extracts diff data from gitsigns
local function gitsigns_diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

local colorless_theme = {
  normal = { a = '', b = '', c = '' },
  insert = { a = '', b = '', c = '' },
  visual = { a = '', b = '', c = '' },
  replace = { a = '', b = '', c = '' },
  command = { a = '', b = '', c = '' },
  inactive = { a = '', b = '', c = '' },
}

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup {
      options = { theme = colorless_theme },
      sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {
          { 'diff', source = gitsigns_diff_source, diff_color = {} },
          'diagnostics',
          'filetype',
        },
        lualine_y = {
          { 'lsp_status', ignore_lsp = { 'typos_lsp' } },
        },
      },
    }
  end,
}
