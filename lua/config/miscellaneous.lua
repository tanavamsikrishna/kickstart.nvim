-- Miscellaneous editor defaults that do not belong in a dedicated module.
--
-- Responsibilities: window title (`NVim <cwd-basename> (<parent path>)`),
-- project-local `exrc`, wrap/linebreak for prose buffers, virtualedit, and
-- command-line abbreviations. Not a plugin spec.

-- Window title: `NVim <cwd-basename> (<parent path>)`.
-- Parent under $HOME uses `~` with full path components; otherwise the parent
-- is the raw dirname.
vim.opt.title = true
local function humanized_parent()
  local home = vim.env.HOME
  local dirname = vim.fs.dirname(vim.fn.getcwd())
  if home and dirname == home then return '~' end
  if home and vim.startswith(dirname, home .. '/') then
    local rel = vim.fs.relpath(home, dirname)
    if rel and rel ~= '.' then return '~/' .. rel end
    return '~'
  end
  return dirname
end
vim.opt.titlestring = vim.fs.basename(vim.fn.getcwd())
  .. ' ('
  .. humanized_parent()
  .. ')'

-- `exrc`
vim.o.exrc = true

-- wrapping
vim.o.wrap = true
vim.o.breakindent = true
vim.opt.linebreak = false
vim.opt.showbreak = '⤷ '

local linebreak_filetypes = { 'markdown', 'quarto', 'rmd', 'text', 'gitcommit' }

vim.api.nvim_create_autocmd({ 'FileType' }, {
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
