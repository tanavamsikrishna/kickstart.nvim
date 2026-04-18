local get_tools = require 'lua.config.required_tools'
local lsp_tools = get_tools 'lsp'
local other_tools = get_tools 'others'

local all_tools = vim.deepcopy(lsp_tools)
vim.list_extend(all_tools, other_tools)
local DEFAULT_TIMEOUT_MS = 30 * 60 * 1000

local function command_to_string(cmd)
  return table.concat(vim.tbl_map(vim.fn.shellescape, cmd), ' ')
end

local function run_command(cmd, timeout_ms)
  local done = false
  local result = { code = 1, signal = 0 }
  local handle
  local spawn_err
  local wait_timeout = timeout_ms or DEFAULT_TIMEOUT_MS

  handle, spawn_err = vim.uv.spawn(cmd[1], {
    args = vim.list_slice(cmd, 2),
    stdio = { 0, 1, 2 },
  }, function(code, signal)
    result.code = code
    result.signal = signal
    done = true
    if handle and not handle:is_closing() then handle:close() end
  end)

  if not handle then return false, tostring(spawn_err or 'failed to spawn command') end

  local completed = vim.wait(wait_timeout, function() return done end, 100)
  if not completed then
    if handle and not handle:is_closing() then handle:kill(15) end
    vim.wait(5000, function() return done end, 100)
    if not done and handle and not handle:is_closing() then handle:kill(9) end
    return false, string.format('timed out after %d ms', wait_timeout)
  end

  return true, result
end

local function build_bin_command(tool)
  local repo_url = tool.pkg
  local bin_name = tool.bin_name
  assert(repo_url and repo_url ~= '', 'tool.pkg must be set and not empty')
  assert(bin_name and bin_name ~= '', 'tool.bin_name must be set and not empty')

  -- Derive the module path from the config directory to avoid hardcoding the full path
  local inner_cmd = string.format(
    'use ($nu.config-path | path dirname | path join modules bin.nu); bin install %s %s',
    repo_url,
    bin_name
  )
  return { 'nu', '-c', inner_cmd }
end

local cmd_map = {
  bun = function(tool) return { 'bun', 'install', '-g', tool.pkg } end,
  bin = build_bin_command,
  uv = function(tool)
    local cmd = { 'uv', 'tool', 'install' }
    for _, with_pkg in ipairs(tool.with_pkgs or {}) do
      table.insert(cmd, '--with')
      table.insert(cmd, with_pkg)
    end
    table.insert(cmd, tool.pkg)
    return cmd
  end,
  luarocks = function(tool)
    local lua_version = tool.lua_version or '5.4'
    local cmd = {
      'mise',
      'exec',
      'lua@' .. lua_version,
      '--',
      'luarocks',
      'install',
      '--local',
      tool.pkg,
    }
    if tool.version then table.insert(cmd, tool.version) end
    if tool.lua_version then
      table.insert(cmd, '--lua-version')
      table.insert(cmd, tool.lua_version)
    end
    return cmd
  end,
  brew = function(tool) return { 'brew', 'install', tool.pkg } end,
}

for _, tool in ipairs(all_tools) do
  local name = type(tool) == 'string' and tool or tool[1]
  if type(tool) == 'table' and tool.pkg and tool.manager then
    local builder = cmd_map[tool.manager]
    if builder then
      local cmd = builder(tool)
      print('Installing ' .. name .. ' via ' .. tool.manager .. '...\n')
      print('> ' .. command_to_string(cmd) .. '\n')
      local ok, result = run_command(cmd, tool.timeout_ms)
      if not ok then
        print(
          'Error: failed to execute install command for '
            .. name
            .. ': '
            .. tostring(result)
        )
        os.exit(1)
      end

      if result.code ~= 0 then
        print(
          'Error: failed to install '
            .. name
            .. ' (exit code: '
            .. tostring(result.code)
            .. ', signal: '
            .. tostring(result.signal)
            .. ')'
        )
        os.exit(1)
      end
    end
  end
end
print 'Installation completed.'
