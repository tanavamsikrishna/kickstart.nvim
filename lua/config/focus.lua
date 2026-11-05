-- Bring the Neovim host window to the front.
--
-- `:Focus` is the public interface. Neovide, Ghostty, and Rex implement one
-- protocol: `matches` (an explicit check, not a fallback), `capture` (record
-- ids at startup while this host is still current), and `focus`. Ghostty
-- matches `TERM_PROGRAM=ghostty` and focuses the terminal id captured then;
-- if that id is unknown, `:Focus` is a no-op. Rex matches `TERM_PROGRAM=rex`
-- and selects this block's session and window, then focuses the block, using
-- ids from `rex block inspect` and `rex client inspect`. An unmatched or
-- unidentified host is left alone; failures are silent.

local term_program = vim.env.TERM_PROGRAM

--- @class FocusHost
--- @field matches fun(self: FocusHost): boolean
--- @field capture fun(self: FocusHost)
--- @field focus fun(self: FocusHost)
local FocusHost = {}
FocusHost.__index = FocusHost

function FocusHost.matches(_) return false end

function FocusHost.capture(_) end

function FocusHost.focus(_) end

--- @param methods table
--- @return FocusHost
local function host(methods) return setmetatable(methods, FocusHost) end

--- @class Neovide : FocusHost
local Neovide = host {}

function Neovide.matches(_) return vim.g.neovide and true or false end

function Neovide:focus()
  if not self:matches() then return end
  vim.api.nvim_cmd({ cmd = 'NeovideFocus' }, {})
end

--- @param script string
--- @param on_done? fun(stdout: string, ok: boolean)
local function osascript(script, on_done)
  vim.system({ 'osascript', '-e', script }, { text = true }, function(obj)
    if not on_done then return end
    vim.schedule(function() on_done(vim.trim(obj.stdout or ''), obj.code == 0) end)
  end)
end

--- @class Ghostty : FocusHost
--- @field terminal_id string?
local Ghostty = host {}

function Ghostty.matches(_) return term_program == 'ghostty' and not vim.g.neovide end

function Ghostty:capture()
  if not self:matches() or vim.fn.has 'macunix' ~= 1 then return end
  osascript(
    'tell application "Ghostty" to id of focused terminal of selected tab of front window',
    function(id, ok)
      if ok and id:match '^[%x-]+$' then self.terminal_id = id end
    end
  )
end

function Ghostty:focus()
  if not self:matches() then return end
  local id = self.terminal_id
  if not id then return end
  osascript(([[tell application "Ghostty"
  activate
  focus (terminal id %q)
end tell]]):format(id))
end

--- @param kind string
--- @param value any
--- @return string?
local function rex_id(kind, value)
  if type(value) ~= 'string' or not value:match('^' .. kind .. ':[%w-]+$') then
    return nil
  end
  return value
end

--- @param args string[]
--- @param on_done? fun(obj: table?)
local function rex(args, on_done)
  local argv = { 'rex', '--color', 'never', '--timeout', '3s' }
  vim.list_extend(argv, args)
  local ok = pcall(vim.system, argv, { text = true }, function(obj)
    if on_done then vim.schedule(function() on_done(obj) end) end
  end)
  if not ok and on_done then vim.schedule(function() on_done(nil) end) end
end

--- @param obj table?
--- @return table?
local function rex_json(obj)
  if not obj or obj.code ~= 0 or not obj.stdout or obj.stdout == '' then return nil end
  local ok, decoded = pcall(vim.json.decode, obj.stdout)
  if not ok or type(decoded) ~= 'table' then return nil end
  return decoded
end

--- @class Rex : FocusHost
local Rex = host {}

function Rex.matches(_) return term_program == 'rex' and not vim.g.neovide end

function Rex:focus()
  if not self:matches() then return end
  local block = vim.env.REX_BLOCK
  if not rex_id('block', block) then return end

  rex({ 'block', 'inspect', block, '--json' }, function(block_obj)
    local decoded = rex_json(block_obj)
    if not decoded then return end
    local info = decoded.block
    if type(info) ~= 'table' then return end

    local ids = {
      session = rex_id('session', decoded.session_id),
      window = rex_id('window', info.window_id),
      block = rex_id('block', info.block_id),
      client = rex_id('client', info.owner),
    }
    if not (ids.session and ids.window and ids.block) then return end

    local client_args = { 'client', 'inspect', '--json' }
    if ids.client then table.insert(client_args, 3, ids.client) end
    rex(client_args, function(client_obj)
      local client = rex_json(client_obj)
      local client_info = client and client.client
      if type(client_info) == 'table' then
        local client_id = rex_id('client', client_info.client_id)
        local kind = type(client_info.info) == 'table' and client_info.info.kind or nil
        if client_id and kind == 'app' then ids.client = client_id end
      end
      if not ids.client then return end

      rex({
        '-C',
        ids.client,
        'do',
        'session.select',
        'session_id=' .. ids.session,
        'window_id=' .. ids.window,
      }, function(select_obj)
        if not select_obj or select_obj.code ~= 0 then return end
        rex { 'focus', '-s', ids.session, '-w', ids.window, ids.block }
      end)
    end)
  end)
end

local hosts = { Neovide, Ghostty, Rex }

--- @return FocusHost?
local function matched_host()
  for _, candidate in ipairs(hosts) do
    if candidate:matches() then return candidate end
  end
end

local function focus()
  local current = matched_host()
  if not current then return end
  current:focus()
end

local current = matched_host()
if current then current:capture() end

vim.api.nvim_create_user_command('Focus', focus, {
  desc = 'Bring the Neovim host window to the front',
})
