---@class ToolType
local tools = {
  lsp = {
    'cssls',
    'jsonls',
    { 'lua_ls', version = '3.16.4' }, -- Fix for lsp not loading on a single file
    'nushell',
    'pyright',
    'rust_analyzer',
    'svelte',
    'tombi',
    'ts_ls',
    'zls',
  },
  formatter = { 'stylua', 'prettierd', 'jq', 'tombi' },
  installation_skipped = { 'nushell' },
}

---@param tool_type 'lsp'|'formatter'|'installation_skipped'
---@return string[]
local function get_necessary_tools(tool_type) return tools[tool_type] end

return get_necessary_tools
