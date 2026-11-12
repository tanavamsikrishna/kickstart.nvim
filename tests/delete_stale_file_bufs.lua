-- Verify JSON-backed global access times, session persistence, and stale-buffer
-- cleanup in Git and non-Git directories without touching the user's state files.
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
vim.env.XDG_STATE_HOME = root .. '/state'
vim.cmd.cd(vim.fn.fnameescape(repo))
dofile(config)
vim.notify = function() end

local function get_times()
  assert(type(vim.g.LocalFileBufferAccessTimes) == 'string', 'state must be JSON')
  return vim.json.decode(vim.g.LocalFileBufferAccessTimes)
end

local probe_path = repo .. '/probe.txt'
local probe = vim.fn.bufadd(probe_path)
local function enter_probe()
  vim.api.nvim_exec_autocmds('BufEnter', { buffer = probe })
end

local function check_fallback(raw)
  vim.g.LocalFileBufferAccessTimes = raw
  enter_probe()
  local times = get_times()
  assert(type(times[probe_path]) == 'number', 'BufEnter must recover invalid state')
  times[probe_path] = nil
  assert(vim.tbl_isempty(times), 'invalid state must fall back to an empty table')
end

check_fallback(nil)
check_fallback('not JSON')
check_fallback('42')
check_fallback('"not a table"')
check_fallback(42)

local startup_times = { [repo .. '/tracked.txt'] = os.time() }
vim.g.LocalFileBufferAccessTimes = vim.json.encode(startup_times)
dofile(config)
assert(
  vim.deep_equal(get_times(), startup_times),
  'loading the module must preserve session-restored access times'
)
enter_probe()
assert(
  get_times()[repo .. '/tracked.txt'] == startup_times[repo .. '/tracked.txt'],
  'BufEnter must preserve existing JSON access times'
)

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
local times = get_times()
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

vim.cmd.cd(vim.fn.fnameescape(outside))
assert(vim.deep_equal(get_times(), times), 'changing CWD must preserve global state')
local no_git_old = add(outside .. '/no-git-old.txt')
local no_git_recent = add(outside .. '/no-git-recent.txt')
times = get_times()
times[outside .. '/no-git-old.txt'] = now - 8 * 24 * 60 * 60
times[outside .. '/no-git-recent.txt'] = now
vim.g.LocalFileBufferAccessTimes = vim.json.encode(times)
vim.cmd.DeleteStaleFileBufs()
assert(
  get_times()[outside .. '/no-git-recent.txt'] == now,
  'cleanup must preserve recent JSON access times'
)
assert(not valid(no_git_old), 'old buffers must be deleted outside Git repositories')
assert(valid(no_git_recent), 'recent buffers must survive outside Git repositories')
vim.api.nvim_set_current_buf(no_git_recent)
assert(
  get_times()[outside .. '/no-git-recent.txt'] >= now,
  'entering a file buffer must record its access time'
)

-- Restore a real session in a separate process using the project's session options.
dofile(config_root .. '/lua/config/mksession.lua')
local exit_path = outside .. '/exit-only.txt'
times = get_times()
times[exit_path] = now
vim.g.LocalFileBufferAccessTimes = vim.json.encode(times)
local session = root .. '/Session.vim'
vim.cmd.mksession(vim.fn.fnameescape(session))
local lua = string.format(
  'dofile(%q); vim.cmd.source(%q); '
    .. 'assert(type(vim.g.LocalFileBufferAccessTimes) == "string"); '
    .. 'assert(vim.json.decode(vim.g.LocalFileBufferAccessTimes)[%q] == %d)',
  config,
  session,
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

print 'delete_stale_file_bufs tests passed'
