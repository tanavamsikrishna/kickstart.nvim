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
  others = {
    'stylua',
    'prettierd',
    'jq',
    'tombi',
    'tree-sitter-cli',
    'jsonlint',
  },
  installation_skipped = { 'nushell' },
}

---@param tool_type 'lsp'|'others'|'installation_skipped'
---@return string[]
local function get_necessary_tools(tool_type) return tools[tool_type] end

return get_necessary_tools
