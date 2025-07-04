-- Delete bufs of files which are not in the current working directory

local delete_ext_file_bufs = function()
  local all_bufs = vim.api.nvim_list_bufs()
  local cwd = vim.fn.getcwd()
  local is_some_buf_deleted = false
  for _, buf_id in ipairs(all_bufs) do
    local file_path = vim.api.nvim_buf_get_name(buf_id)
    if file_path ~= '' and file_path:find(cwd) == nil then
      print('Deleting buffer ' .. file_path)
      vim.api.nvim_buf_delete(buf_id, { force = false, unload = false })
      is_some_buf_deleted = is_some_buf_deleted or true
    end
  end
  if not is_some_buf_deleted then
    print 'No buffers deleted'
  end
end

vim.api.nvim_create_user_command(
  'DeleteExtFileBufs',
  delete_ext_file_bufs,
  { desc = 'Delete buffers of all files which are no in the current working directory' }
)
