-- Use a local variable to restore original cursor settings
local original_guicursor = vim.opt.guicursor:get()
local hide_cursor = function()
  -- Create a hidden cursor highlight
  vim.api.nvim_set_hl(0, 'HiddenCursor', { blend = 100, nocombine = true })
  vim.opt.guicursor:append 'a:HiddenCursor'
end
local reset_cursor = function()
  vim.opt.guicursor = original_guicursor
end

-- Create an autocommand group for NvimTree cursor management
local group = vim.api.nvim_create_augroup('NvimTreeHideCursor', { clear = true })

-- Hide cursor on entry
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'CmdLineLeave' }, {
  group = group,
  buffer = 0,
  callback = hide_cursor,
})

-- Show cursor on exit
vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave', 'CmdLineEnter' }, {
  group = group,
  buffer = 0,
  callback = reset_cursor,
})
