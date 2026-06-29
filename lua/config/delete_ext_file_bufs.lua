-- Delete bufs of files which are not in the current working directory

local delete_ext_file_bufs = function()
  local git_lsfiles_output = vim
    .system({ 'git', 'ls-files', '--cached', '--others', '--exclude-standard' }, { text = true })
    :wait()
  if git_lsfiles_output.code ~= 0 then
    vim.notify('Git ls-files failed' .. (git_lsfiles_output.stderr or ''), 'error')
    return
  end
  local working_dir_files = vim.fn.split(git_lsfiles_output.stdout or '', '\n', false)

  local all_bufs = vim.api.nvim_list_bufs()
  local cwd = vim.fn.getcwd() .. '/'
  local is_some_buf_deleted = false
  for _, buf_id in ipairs(all_bufs) do
    if not vim.api.nvim_get_option_value('buflisted', { buf = buf_id }) then goto continue end
    local file_path = vim.api.nvim_buf_get_name(buf_id)
    if file_path == '' then goto continue end
    local pwd_string_index_start, pwd_string_index_end = file_path:find(cwd)
    if pwd_string_index_start ~= 1 then goto delete end

    do
      local relative_file_path = file_path:sub(pwd_string_index_end + 1)
      if vim.tbl_contains(working_dir_files, relative_file_path) then goto continue end
    end

    ::delete::
    vim.notify('Deleting buffer ' .. file_path)
    vim.api.nvim_buf_delete(buf_id, { force = false, unload = false })
    is_some_buf_deleted = is_some_buf_deleted or true

    ::continue::
  end
  if not is_some_buf_deleted then vim.notify 'No buffers deleted' end
end

vim.api.nvim_create_user_command('DeleteExtFileBufs', delete_ext_file_bufs, {
  desc = 'Delete buffers of all files which are neither in the current working directory'
    .. ' nor tracked by git',
})
