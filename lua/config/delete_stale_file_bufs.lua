-- Track file-buffer access, persist CWD-scoped access times, and remove stale
-- or Git-unlisted buffers. Load at startup/before cleanup; save after cleanup/on exit.
-- Git failures fall back to age-based cleanup; modified buffers are never forced.

local utils = require 'utils'
local state_file = 'buffer-access-times.json'
local group = vim.api.nvim_create_augroup('TrackBufferAccess', { clear = true })

local function load_access_times()
  local stored = utils.read_cwd_json(state_file)
  if type(stored) ~= 'table' then stored = {} end
  vim.g.LocalFileBufferAccessTimes =
    vim.tbl_extend('force', stored, vim.g.LocalFileBufferAccessTimes or {})
end

local function save_access_times()
  local ok, err = utils.write_cwd_json(
    state_file,
    vim.g.LocalFileBufferAccessTimes or vim.empty_dict()
  )
  if not ok then
    vim.notify('Could not save buffer access times: ' .. err, vim.log.levels.WARN)
  end
end

load_access_times()

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  callback = save_access_times,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname ~= '' and vim.bo[args.buf].buftype == '' then
      -- Directly editing BufferAccessTime in Lua is not going to
      -- update the underlying vim dictionary
      local times = vim.g.LocalFileBufferAccessTimes or {}
      times[bufname] = os.time()
      vim.g.LocalFileBufferAccessTimes = times
    end
  end,
})

local function delete_stale_file_bufs()
  load_access_times()
  local git_files = nil
  local git_lsfiles_output = vim
    .system({ 'git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z' })
    :wait()
  if git_lsfiles_output.code == 0 then
    local cwd = vim.fn.getcwd()
    local paths = vim.split(
      git_lsfiles_output.stdout or '',
      '\0',
      { plain = true, trimempty = true }
    )
    git_files = {} -- Denotes CWD in a git repo
    for _, path in ipairs(paths) do
      git_files[vim.fs.normalize(cwd .. '/' .. path)] = true
    end
  end

  local access_times = vim.g.LocalFileBufferAccessTimes or {}
  local cutoff = os.time() - 7 * 24 * 60 * 60

  local function should_delete(buf)
    if vim.bo[buf].modified then return false, 'Modified buffer' end
    if vim.bo[buf].buftype ~= '' then return true, 'Non-file buffer' end
    local path = vim.api.nvim_buf_get_name(buf)
    if path == '' then return false, 'Unnamed buffer' end
    local last_access = access_times[path]
    if git_files ~= nil and not git_files[path] then
      return true, 'Not a local vcs file'
    end
    return last_access == nil or last_access < cutoff, 'No recent access'
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local path = vim.api.nvim_buf_get_name(buf)
    local to_delete, reason = should_delete(buf)
    if to_delete then
      local ok, err =
        pcall(vim.api.nvim_buf_delete, buf, { force = false, unload = false })
      access_times[path] = nil
      if ok then
        vim.notify('Deleted ' .. buf .. ' ' .. path .. ', reason: ' .. reason)
      else
        vim.notify(
          'Could not delete buffer ' .. path .. ': ' .. tostring(err),
          vim.log.levels.WARN
        )
      end
    end
  end

  for path in ipairs(vim.tbl_keys(access_times)) do
    if access_times[path] ~= nil and access_times[path] < cutoff then
      access_times[path] = nil
    end
  end

  vim.g.LocalFileBufferAccessTimes = access_times
  save_access_times()
end

vim.api.nvim_create_user_command('DeleteStaleFileBufs', delete_stale_file_bufs, {
  desc = 'Delete file buffers not listed by Git or not accessed in the last seven days',
})
