-- Up/Down rewiring
local _key_mapping = { 'j', 'k' }
for _, vim_key in ipairs(_key_mapping) do
  vim.keymap.set(
    { 'n', 'v' },
    vim_key .. vim_key,
    function() return vim.v.count == 0 and ('g' .. vim_key) or vim_key end,
    { expr = true, silent = true }
  )
end
