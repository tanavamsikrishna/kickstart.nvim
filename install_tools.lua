local get_tools = require 'lua.config.required_tools'
local lsp_tools = get_tools 'lsp'
local other_tools = get_tools 'others'

local all_tools = vim.deepcopy(lsp_tools)
vim.list_extend(all_tools, other_tools)

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
  return string.format("nu --config $(nu -c '$nu.config-path') -c '%s'", inner_cmd)
end

local cmd_map = {
  bun = function(tool) return string.format('bun install -g %s', tool.pkg) end,
  bin = build_bin_command,
  uv = function(tool) return string.format('uv tool install %s', tool.pkg) end,
  luarocks = function(tool)
    local pkg = tool.pkg
    if tool.version then pkg = pkg .. ' ' .. tool.version end
    local lua_version = tool.lua_version or '5.4'
    local luarocks_cmd = string.format('luarocks install --local %s', pkg)
    if tool.lua_version then
      luarocks_cmd = luarocks_cmd .. ' --lua-version ' .. tool.lua_version
    end
    return string.format('mise exec lua@%s -- %s', lua_version, luarocks_cmd)
  end,
}

for _, tool in ipairs(all_tools) do
  local name = type(tool) == 'string' and tool or tool[1]
  if type(tool) == 'table' and tool.pkg and tool.manager then
    local builder = cmd_map[tool.manager]
    if builder then
      local cmd = builder(tool)
      print('Installing ' .. name .. ' via ' .. tool.manager .. '...\n')
      local success, reason, status = os.execute(cmd)
      if not success then
        print(
          'Error: failed to install '
            .. name
            .. ' ('
            .. reason
            .. ' status: '
            .. tostring(status)
            .. ')'
        )
        os.exit(1)
      end
    end
  end
end
print 'Installation completed.'
