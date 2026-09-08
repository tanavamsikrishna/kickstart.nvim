-- Miscellaneous editor defaults that do not belong in a dedicated module.
--
-- Responsibilities: window title from a Nushell-style abbreviated cwd,
-- project-local `exrc`, wrap/linebreak for prose buffers, virtualedit, and
-- command-line abbreviations. Not a plugin spec.

-- Window title. `humanized_pwd` matches the Nushell prompt: `~` at home,
-- first two characters of each parent under home, full last component;
-- otherwise the raw path.
vim.opt.title = true
local function humanized_pwd()
  local home = vim.env.HOME
  local pwd = vim.fn.getcwd()
  if home and pwd == home then return '~' end
  if not home or not vim.startswith(pwd, home .. '/') then return pwd end

  local basename = vim.fs.basename(pwd)
  local dirname = vim.fs.dirname(pwd)
  local parts = { '~' }
  local rel = vim.fs.relpath(home, dirname)
  if rel and rel ~= '.' then
    for _, component in ipairs(vim.split(rel, '/', { plain = true, trimempty = true })) do
      parts[#parts + 1] = vim.fn.strcharpart(component, 0, 2)
    end
  end
  parts[#parts + 1] = basename
  return table.concat(parts, '/')
end
vim.opt.titlestring = 'Nvim ' .. humanized_pwd()

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
