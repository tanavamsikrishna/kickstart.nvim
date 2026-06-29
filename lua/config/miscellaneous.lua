-- Set title to the current working directory
vim.opt.title = true
vim.opt.titlestring = 'Neovide ' .. vim.fn.getcwd()

-- `exrc`
vim.o.exrc = true

-- wrapping
vim.o.wrap = true
vim.opt.linebreak = false

local linebreak_filetypes = { 'markdown', 'quarto', 'rmd', 'text', 'gitcommit' }

vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter', 'WinEnter' }, {
  desc = 'Use linebreak only for prose windows',
  group = vim.api.nvim_create_augroup('ProseLinebreak', { clear = true }),
  callback = function()
    vim.opt_local.linebreak = vim.tbl_contains(linebreak_filetypes, vim.bo.filetype)
  end,
})

-- `virtualedit` (for cursor movement)
vim.opt.virtualedit = { 'block' }

-- Abbreviations/Remapping
vim.keymap.set('ca', 'w', function()
  if vim.fn.getcmdtype() == ':' and vim.fn.getcmdline() == 'w' then
    return 'update'
  else
    return 'w'
  end
end, { expr = true })

-- Page Up/Down rewiring
vim.keymap.set('', '<PageUp>', '20<C-y>', { remap = false })
vim.keymap.set('', '<PageDown>', '20<C-e>', { remap = false })
