local view_group = vim.api.nvim_create_augroup('AutoView', { clear = true })

-- SAVE VIEW
vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufWritePost', 'WinLeave' }, {
  desc = 'Save view strictly with validation',
  group = view_group,
  pattern = '?*', -- Optimization: Only triggers for files with names
  callback = function(args)
    -- 1. VALIDITY CHECK (Crucial for nvim-tree)
    -- This prevents the "Invalid buffer id" crash you just encountered.
    if not vim.api.nvim_buf_is_valid(args.buf) then return end

    -- 2. Buftype Check (Don't save NvimTree/Telescope views)
    if vim.bo[args.buf].buftype ~= '' then return end

    -- 3. File Existence Check (Crucial for nvim-tree 'trash/delete')
    -- If the file was just deleted, args.file still has the path, but it's not on disk.
    -- We must NOT try to save a view for a deleted file.
    if vim.fn.filereadable(args.file) == 0 then return end

    -- 5. Save
    -- Use 'mkview!' to force overwrite.
    vim.cmd 'mkview!'
  end,
})

-- LOAD VIEW
vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Load view safely',
  group = view_group,
  pattern = '?*',
  callback = function(args)
    -- We still check buftype here to avoid loading views on help/terminal buffers
    if vim.bo[args.buf].buftype == '' then
      -- silent! ignores E185 (Missing file) and E484 (Read error)
      vim.cmd 'silent! loadview'
    end
  end,
})

vim.opt.viewoptions = { 'folds', 'cursor' }
