-- Run with: nvim --clean --headless -l scripts/probe.lua ...
-- Probe code is executed by the target, not by this client.
local usage = [[
Usage: nvim --clean --headless -l scripts/probe.lua SOCKET COMMAND
  state               Target identity, current context, and attached UIs
  messages            Last 20 entries in the target's message history
  lua CODE [ARG ...]  Execute a Lua chunk on the target
  file PATH [ARG ...] Send Lua source from a local file to the target
  stdin [ARG ...]     Send Lua source from stdin to the target

SOCKET must be an absolute path to a local Unix-domain socket.
Custom probes receive ARG strings as ... and should return a small value.
Use a caller-side deadline: this runner waits synchronously for the reply.
]]

local function fail(stage, message)
  io.stderr:write(('nvim-probe [%s]: %s\n'):format(stage, tostring(message)))
  os.exit(1)
end

if arg[1] == '--help' then
  io.stdout:write(usage)
  return
end

local socket, command = arg[1], arg[2]
if not socket or socket:sub(1, 1) ~= '/' or not command then fail('usage', usage) end
if not vim.uv then fail('client', 'Neovim 0.10 or newer is required') end

local builtin = {
  state = [[
    local api = vim.api
    local win = api.nvim_get_current_win()
    local buf = api.nvim_win_get_buf(win)
    local v = vim.version()
    return {
      pid = vim.fn.getpid(),
      version = {
        major = v.major, minor = v.minor, patch = v.patch,
        prerelease = v.prerelease,
      },
      servername = vim.v.servername,
      vim_did_enter = vim.v.vim_did_enter,
      tab = api.nvim_get_current_tabpage(),
      win = win,
      buf = buf,
      filetype = api.nvim_get_option_value("filetype", { buf = buf }),
      mode = api.nvim_get_mode(),
      uis = api.nvim_list_uis(),
    }
  ]],
  messages = [[
    return vim.api.nvim_exec2("20messages", { output = true }).output
  ]],
}

local max_bytes = 64 * 1024
local code, first_arg = builtin[command], 3
if code then
  if arg[3] ~= nil then fail('usage', command .. ' takes no extra arguments') end
elseif command == 'lua' then
  code, first_arg = arg[3], 4
elseif command == 'file' then
  if not arg[3] then fail('usage', 'file requires a Lua source path') end
  local file, err = io.open(arg[3], 'rb')
  if not file then fail('source', err) end
  code, err = file:read(max_bytes + 1)
  file:close()
  if err then fail('source', err) end
  first_arg = 4
elseif command == 'stdin' then
  local err
  code, err = io.stdin:read(max_bytes + 1)
  if err then fail('source', err) end
else
  fail('usage', 'unknown command: ' .. command .. '\n' .. usage)
end
if not code or not code:find '%S' then fail('source', 'empty Lua chunk') end
if #code > max_bytes then fail('source', 'Lua chunk exceeds 64 KiB') end

local args = {}
for i = first_arg, #arg do
  args[#args + 1] = arg[i]
end

local stat, stat_err = vim.uv.fs_stat(socket)
if not stat then fail('socket', stat_err or socket) end
if stat.type ~= 'socket' then fail('socket', 'not a Unix-domain socket: ' .. socket) end

local connected, chan = pcall(vim.fn.sockconnect, 'pipe', socket, { rpc = true })
if not connected then fail('connect', chan) end
if chan <= 0 then fail('connect', 'no RPC channel for ' .. socket) end

local ok, result = pcall(vim.rpcrequest, chan, 'nvim_exec_lua', code, args)
pcall(vim.fn.chanclose, chan)
if not ok then fail('rpc', result) end

if result == nil then result = vim.NIL end
local encoded, json = pcall(vim.json.encode, result)
if not encoded then fail('json', json) end
if #json + 1 > max_bytes then
  fail('output', 'JSON exceeds 64 KiB; narrow the probe on the target')
end
local written, write_err = io.stdout:write(json, '\n')
if not written then fail('stdout', write_err) end
