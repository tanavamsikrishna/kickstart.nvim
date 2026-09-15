-- Activate the Neovim host window (Neovide GUI, otherwise Ghostty).
--
-- `:Focus` is the public interface. Inside Neovide it runs `:NeovideFocus`.
-- Inside Ghostty it focuses this instance's terminal by id, captured at
-- startup with async osascript (the launching tab is still selected). If the
-- id is unknown, `:Focus` is a no-op.

local function focus_neovide() vim.api.nvim_cmd({ cmd = 'NeovideFocus' }, {}) end

--- @param script string
--- @param on_done? fun(stdout: string, ok: boolean)
local function osascript(script, on_done)
  vim.system({ 'osascript', '-e', script }, { text = true }, function(obj)
    if not on_done then return end
    vim.schedule(function() on_done(vim.trim(obj.stdout or ''), obj.code == 0) end)
  end)
end

local function focus_ghostty()
  local id = vim.g._focus_ghostty_terminal_id
  if not id then return end
  osascript(([[tell application "Ghostty"
  activate
  focus (terminal id %q)
end tell]]):format(id))
end

local function capture_ghostty_terminal_id()
  osascript(
    'tell application "Ghostty" to id of focused terminal of selected tab of front window',
    function(id, ok)
      if ok and id:match '^[%x-]+$' then vim.g._focus_ghostty_terminal_id = id end
    end
  )
end

if not vim.g.neovide and vim.fn.has 'macunix' == 1 then
  capture_ghostty_terminal_id()
end

local function focus()
  if vim.g.neovide then
    focus_neovide()
  else
    focus_ghostty()
  end
end

vim.api.nvim_create_user_command('Focus', focus, {
  desc = 'Bring the Neovim host window to the front',
})
