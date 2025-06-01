-- Fix UI issues
vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { bold = true })
vim.api.nvim_set_hl(0, 'DiagnosticFloatingHint', { link = 'DiagnosticFloatingInfo' })

-- Changing default setting for neo-tree
require('neo-tree').setup { window = { position = 'float' }, default_source = 'last' }

return {}
