--- Persist and restore per-file cursor/fold views (`mkview` / `loadview`).
---
--- Skips invalid buffers, non-file buftypes, missing files, dependency trees,
--- and paths whose encoded view filename would exceed NAME_MAX (255). A mkview
--- failure is reported and swallowed so it cannot abort the jump that left the
--- window (`gd` does this via the mini picker).
---
--- `should_persist(path)` is the shared gate. folding.lua uses it before mkview.

local M = {}

-- Whole path components that root a third-party tree. Not substrings:
-- `vendor_regex` is not `vendor`. Cargo checkouts are only `.cargo/registry`
-- and `.cargo/git`, so `~/.cargo/config.toml` still persists.
local DEPENDENCY_DIR = {
  ['node_modules'] = true,
  ['.pnpm'] = true,
  ['bower_components'] = true,
  ['site-packages'] = true,
  ['.venv'] = true,
  ['venv'] = true,
  ['vendor'] = true,
  ['vendored'] = true,
  ['third_party'] = true,
  ['third-party'] = true,
  ['Pods'] = true,
}

-- macOS / APFS / ext4 filename component limit. `:mkview` puts the whole
-- escaped path in one filename under 'viewdir'.
local NAME_MAX = 255

local function is_dependency(path)
  local prev
  for part in path:gmatch '[^/]+' do
    if DEPENDENCY_DIR[part] then return true end
    if prev == '.cargo' and (part == 'registry' or part == 'git') then return true end
    prev = part
  end
  return false
end

--- Basename `:mkview` writes under 'viewdir' (no view number).
--- Matches `get_view_file()` in Neovim's ex_session.c: home becomes `~`,
--- `=` becomes `==`, `/` becomes `=+`, trailing `=`.
function M.view_filename(path)
  local name = vim.fn.fnamemodify(path, ':p:~')
  return (name:gsub('=', '=='):gsub('/', '=+')) .. '='
end

--- False for dependency trees and names that cannot be opened as a view file.
--- `path` must be the buffer name: `:mkview` encodes that (often symlink-resolved),
--- and `:p` does not resolve symlinks.
function M.should_persist(path)
  if type(path) ~= 'string' or path == '' then return false end
  local full = vim.fn.fnamemodify(path, ':p')
  if is_dependency(full) then return false end
  return #M.view_filename(full) <= NAME_MAX
end

local function save_view()
  -- A thrown error here aborts the command that fired BufWinLeave, including
  -- the buffer switch inside a gd jump.
  local ok, err = pcall(vim.cmd, 'mkview!')
  if ok then return end
  local msg = tostring(err):match '^[^\n]*' or tostring(err)
  vim.notify_once('mkview failed: ' .. msg, vim.log.levels.WARN)
end

local view_group = vim.api.nvim_create_augroup('AutoView', { clear = true })

-- SAVE VIEW
vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufWritePost', 'WinLeave' }, {
  desc = 'Save view strictly with validation',
  group = view_group,
  pattern = '?*', -- Only triggers for files with names
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) then return end
    if vim.bo[args.buf].buftype ~= '' then return end
    -- args.file still names a just-deleted file; do not save a view for it.
    if vim.fn.filereadable(args.file) == 0 then return end
    if not M.should_persist(vim.api.nvim_buf_get_name(args.buf)) then return end
    -- mkview writes the current buffer, which can differ from args.buf.
    local current = vim.api.nvim_buf_get_name(0)
    if current ~= '' and not M.should_persist(current) then return end
    if vim.fn.expand '%' == '' then return end
    save_view()
  end,
})

-- LOAD VIEW
vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Load view safely',
  group = view_group,
  pattern = '?*',
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) then return end
    if vim.bo[args.buf].buftype ~= '' then return end
    if not M.should_persist(vim.api.nvim_buf_get_name(args.buf)) then return end
    -- silent! ignores E185 (missing file) and E484 (read error)
    vim.cmd 'silent! loadview'
  end,
})

vim.opt.viewoptions = { 'folds', 'cursor' }

return M
