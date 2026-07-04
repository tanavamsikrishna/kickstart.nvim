-- Configure alternative way of moving in the buffer

-- Page Up/Down rewiring
vim.keymap.set('', '<PageUp>', '20<C-y>', { remap = false })
vim.keymap.set('', '<PageDown>', '20<C-e>', { remap = false })

-- Up/Down rewiring
local _key_mapping = { ['<Down>'] = 'j', ['<Up>'] = 'k' }
for arrow, vim_key in pairs(_key_mapping) do
  vim.keymap.set(
    { 'n', 'v' },
    arrow,
    function() return vim.v.count == 0 and 'g' .. vim_key or vim_key end,
    { expr = true, silent = true }
  )
end
