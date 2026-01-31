local view_group = vim.api.nvim_create_augroup('AutoView', { clear = true })

vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufWritePost', 'WinLeave' }, {
  desc = 'Save view strictly',
  group = view_group,
  callback = function(args)
    -- Filter invalid buffers
    if vim.bo[args.buf].buftype ~= '' then return end
    if vim.api.nvim_buf_get_name(args.buf) == '' then return end

    -- Enforce Manual Mode before saving
    vim.api.nvim_buf_set_option(args.buf, 'foldmethod', 'manual')

    -- Save (Blow up if errors)
    vim.cmd 'mkview!'
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Load view strictly',
  group = view_group,
  callback = function(args)
    -- Check 1: Must be a real file type (not terminal, help, etc.)
    if vim.bo[args.buf].buftype ~= '' then return end
    -- This handles the "No Name" buffer when you start nvim
    local file_path = vim.api.nvim_buf_get_name(args.buf)
    if file_path == '' then return end

    -- Check 3: Logic to load view
    local status, err = pcall(vim.cmd, 'loadview')
    if not status then
      -- Ignore "E185: Cannot find view file" (Normal for new/unvisited files)
      if string.find(err, 'E185') then
        return
      else
        -- Blow up on everything else (Corrupt views, E32, etc.)
        error('Loadview Failed: ' .. err)
      end
    end
  end,
})

vim.opt.viewoptions = { 'folds', 'cursor', 'curdir' }
