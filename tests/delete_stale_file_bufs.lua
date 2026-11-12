-- Verify CWD-scoped JSON persistence and stale-buffer cleanup in Git and non-Git
-- directories, without touching the user's state files.
-- Run with: nvim --headless -u NONE -l tests/delete_stale_file_bufs.lua

local function run(cmd)
  local result = vim.system(cmd, { text = true }):wait()
  assert(result.code == 0, result.stderr)
end

local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
root = assert(vim.uv.fs_realpath(root))
local repo = root .. '/repo'
local outside = root .. '/outside'
vim.fn.mkdir(repo, 'p')
vim.fn.mkdir(outside, 'p')
run { 'git', 'init', '-q', repo }
vim.fn.writefile({ 'ignored*.txt' }, repo .. '/.gitignore')
vim.fn.writefile({ 'tracked' }, repo .. '/tracked.txt')
vim.fn.writefile({ 'untracked' }, repo .. '/untracked.txt')
vim.fn.writefile({ 'ignored' }, repo .. '/ignored.txt')
vim.fn.writefile({ 'modified' }, repo .. '/ignored-modified.txt')
vim.fn.writefile({ 'old' }, repo .. '/old-listed.txt')
vim.fn.writefile({ 'unusual' }, repo .. '/line\nbreak.txt')
vim.fn.writefile({ 'entry' }, repo .. '/entry-only.txt')
run { 'git', '-C', repo, 'add', 'tracked.txt' }

local config_root = vim.fn.getcwd()
local config = config_root .. '/lua/config/delete_stale_file_bufs.lua'
package.path = config_root .. '/lua/?.lua;' .. package.path
vim.env.XDG_STATE_HOME = root .. '/state'
local utils = require 'utils'
local filename = 'buffer-access-times.json'
vim.cmd.cd(vim.fn.fnameescape(repo))

local function state_file(cwd, name)
  cwd = vim.fs.normalize(cwd)
  local folder = vim.fs.basename(cwd):gsub('[^%w%-_]', '_')
  return vim.fn.stdpath 'state'
    .. '/'
    .. folder
    .. '-'
    .. vim.fn.sha256(cwd):sub(1, 12)
    .. '/'
    .. name
end

assert(utils.read_cwd_json(filename) == nil, 'missing state must return nil')
local sample = { nested = { value = 'hello' }, list = { 1, 2 }, flag = true }
assert(utils.write_cwd_json('sample.json', sample))
assert(vim.deep_equal(utils.read_cwd_json 'sample.json', sample))
assert(vim.fn.filereadable(state_file(repo, 'sample.json')) == 1)
vim.fn.writefile({ 'not JSON' }, state_file(repo, 'broken.json'))
local broken, decode_error = utils.read_cwd_json 'broken.json'
assert(broken == nil and decode_error, 'invalid JSON must return an error')

local other_repo = root .. '/other/repo'
vim.fn.mkdir(other_repo, 'p')
vim.cmd.cd(vim.fn.fnameescape(other_repo))
assert(utils.read_cwd_json 'sample.json' == nil, 'same basenames must be isolated')
assert(utils.write_cwd_json('sample.json', { other = true }))
vim.cmd.cd(vim.fn.fnameescape(repo))
assert(vim.deep_equal(utils.read_cwd_json 'sample.json', sample))

vim.fn.writefile({ 'not JSON' }, state_file(repo, filename))
dofile(config)
assert(
  vim.tbl_isempty(vim.g.LocalFileBufferAccessTimes),
  'invalid persisted state must fall back to empty access times'
)
local startup_times = { [repo .. '/tracked.txt'] = os.time() }
assert(utils.write_cwd_json(filename, startup_times))
dofile(config)
assert(
  vim.deep_equal(vim.g.LocalFileBufferAccessTimes, startup_times),
  'startup must load persisted access times'
)
vim.notify = function() end

local function add(path) return vim.fn.bufadd(path) end
local function valid(buf) return vim.api.nvim_buf_is_valid(buf) end
local now = os.time()
local tracked = add(repo .. '/tracked.txt')
local untracked = add(repo .. '/untracked.txt')
local unusual = add(repo .. '/line\nbreak.txt')
local ignored = add(repo .. '/ignored.txt')
local old = add(outside .. '/old.txt')
local never = add(outside .. '/never.txt')
local recent = add(outside .. '/recent.txt')
local modified = add(repo .. '/ignored-modified.txt')
local old_listed = add(repo .. '/old-listed.txt')
vim.fn.bufload(modified)
vim.api.nvim_buf_set_lines(modified, 0, -1, false, { 'unsaved changes' })
vim.g.LocalFileBufferAccessTimes = {
  [repo .. '/tracked.txt'] = now,
  [repo .. '/untracked.txt'] = now,
  [repo .. '/line\nbreak.txt'] = now,
  [repo .. '/entry-only.txt'] = now,
  [repo .. '/ignored.txt'] = now,
  [repo .. '/ignored-entry.txt'] = now,
  [repo .. '/ignored-modified.txt'] = now,
  [repo .. '/old-listed.txt'] = now - 8 * 24 * 60 * 60,
  [outside .. '/old.txt'] = now - 8 * 24 * 60 * 60,
  [outside .. '/recent.txt'] = now,
  [outside .. '/old-entry.txt'] = now - 8 * 24 * 60 * 60,
  [outside .. '/recent-entry.txt'] = now,
}

vim.cmd.DeleteStaleFileBufs()
assert(valid(tracked), 'recent tracked file listed by Git must be retained')
assert(valid(untracked), 'recent untracked file listed by Git must be retained')
assert(valid(unusual), 'Git filenames with newlines must be matched')
assert(not valid(ignored), 'ignored file omitted by Git must be deleted')
assert(not valid(old_listed), 'old listed file must be deleted')
assert(not valid(old), 'old outside buffer must be deleted')
assert(not valid(never), 'buffer without access time must be deleted')
assert(not valid(recent), 'outside buffer omitted by Git must be deleted')
assert(valid(modified), 'unsaved changes must not be discarded')
local times = vim.g.LocalFileBufferAccessTimes
assert(times[repo .. '/tracked.txt'] == now and times[repo .. '/untracked.txt'] == now)
assert(
  times[repo .. '/entry-only.txt'] == now,
  'Git-listed access records must be retained'
)
assert(
  times[repo .. '/ignored-entry.txt'] == now,
  'cleanup must not remove recent records without buffers just for being unlisted'
)
assert(times[outside .. '/old.txt'] == nil)
assert(times[repo .. '/ignored.txt'] == nil)
assert(times[outside .. '/recent-entry.txt'] == now)
assert(
  times[repo .. '/ignored-modified.txt'] == now,
  'modified buffers must retain access times'
)

assert(
  vim.deep_equal(utils.read_cwd_json(filename), times),
  'cleanup must save the resulting access times'
)

vim.cmd.cd(vim.fn.fnameescape(outside))
assert(utils.read_cwd_json(filename) == nil, 'changing CWD must not save state')
local no_git_old = add(outside .. '/no-git-old.txt')
local no_git_recent = add(outside .. '/no-git-recent.txt')
times = vim.g.LocalFileBufferAccessTimes
times[outside .. '/no-git-old.txt'] = now - 8 * 24 * 60 * 60
times[outside .. '/no-git-recent.txt'] = now
vim.g.LocalFileBufferAccessTimes = times
assert(utils.write_cwd_json(filename, {
  [outside .. '/no-git-recent.txt'] = now - 1,
  [outside .. '/disk-only.txt'] = now,
}))
vim.cmd.DeleteStaleFileBufs()
assert(
  vim.g.LocalFileBufferAccessTimes[outside .. '/disk-only.txt'] == now,
  'cleanup must reload persisted records'
)
assert(
  vim.g.LocalFileBufferAccessTimes[outside .. '/no-git-recent.txt'] == now,
  'in-memory access times must take precedence over persisted records'
)
assert(not valid(no_git_old), 'old buffers must be deleted outside Git repositories')
assert(valid(no_git_recent), 'recent buffers must survive outside Git repositories')
vim.api.nvim_set_current_buf(no_git_recent)
assert(
  vim.g.LocalFileBufferAccessTimes[outside .. '/no-git-recent.txt'] >= now,
  'entering a file buffer must record its access time'
)

-- Use a separate process to exercise the real quit event, not just its callback.
local exit_path = outside .. '/exit-only.txt'
local lua = string.format(
  "package.path = %q .. '/lua/?.lua;' .. package.path; "
    .. 'dofile(%q); vim.g.LocalFileBufferAccessTimes = { [%q] = %d }',
  config_root,
  config,
  exit_path,
  now
)
local child = vim
  .system({
    vim.v.progpath,
    '--headless',
    '-u',
    'NONE',
    '-i',
    'NONE',
    '-c',
    'lua ' .. lua,
    '-c',
    'qa!',
  }, { cwd = outside, text = true })
  :wait()
assert(child.code == 0, child.stderr)
assert(
  utils.read_cwd_json(filename)[exit_path] == now,
  'quitting Neovim must save access times for the current CWD'
)

print 'delete_stale_file_bufs tests passed'
