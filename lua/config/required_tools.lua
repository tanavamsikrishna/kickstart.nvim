---@class ToolType
local tools = {
  lsp = {
    'cssls',
    'harper_ls',
    'jsonls',
    'nushell',
    'pyright',
    'rust_analyzer',
    'svelte',
    'tombi',
    'ts_ls',
    'typos_lsp',
    'zls',
    'gopls',
    { 'lua_ls', version = '3.16.4' }, -- Fix for LSP not loading on a single file
  },
  others = {
    'jq',
    'jsonlint',
    'prettierd',
    'stylua',
    'tree-sitter-cli',
  },
  installation_skipped = { 'nushell' },
}

---@param tool_type 'lsp'|'others'|'installation_skipped'
---@return string[]
local function get_necessary_tools(tool_type) return tools[tool_type] end

return get_necessary_tools
