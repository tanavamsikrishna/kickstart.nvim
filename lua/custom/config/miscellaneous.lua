-- Fix UI issues
vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { bold = true })
vim.api.nvim_set_hl(0, 'DiagnosticFloatingHint', { link = 'DiagnosticFloatingInfo' })
vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = 'darkblue' })
vim.api.nvim_set_hl(0, 'MatchParen', { bg = 'lightblue' })

-- Set title to the current working directory
vim.opt.title = true
vim.opt.titlestring = vim.fs.basename(vim.fn.getcwd())

-- exrc
vim.o.exrc = true
