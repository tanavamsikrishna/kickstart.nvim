-- Single source of truth for required LSPs and external tools.
-- Provides tools necessary for Neovim config to function optimally.
-- The format allows neovim to natively load the LSP using the first element,
-- and custom scripts (e.g. `install_tools.lua`) to install them globally.

---@class ToolType
local tools = {
  lsp = {
    { 'cssls', pkg = 'vscode-langservers-extracted', manager = 'bun' },
    --[[ {
      'harper_ls',
      pkg = 'https://github.com/elijah-potter/harper',
      manager = 'bin',
      bin_name = 'harper-ls',
    }, ]]
    { 'jsonls', pkg = 'vscode-langservers-extracted', manager = 'bun' },
    {
      'marksman',
      pkg = 'https://github.com/artempyanykh/marksman',
      manager = 'bin',
      bin_name = 'marksman',
    },
    'nushell',
    { 'pyright', pkg = 'pyright', manager = 'bun' },
    {
      'rust_analyzer',
      pkg = 'https://github.com/rust-lang/rust-analyzer',
      manager = 'bin',
      bin_name = 'rust-analyzer',
    },
    { 'svelte', pkg = 'svelte-language-server', manager = 'bun' },
    { 'tombi', pkg = 'tombi', manager = 'uv' },
    {
      'typos_lsp',
      pkg = 'https://github.com/tekumara/typos-vscode',
      manager = 'bin',
      bin_name = 'typos-lsp',
    },
    { 'vtsls', pkg = '@vtsls/language-server', manager = 'bun' },
    { 'zls', pkg = 'https://github.com/zigtools/zls', manager = 'bin', bin_name = 'zls' },
    { 'lua_ls', pkg = 'lua-language-server', manager = 'brew ' },
  },
  others = {
    { 'eslint_d', pkg = 'eslint_d', manager = 'bun' },
    { 'jq', pkg = 'https://github.com/stedolan/jq', manager = 'bin', bin_name = 'jq' },
    { 'jsonlint', pkg = 'jsonlint', manager = 'bun' },
    { 'luacheck', pkg = 'luacheck', manager = 'luarocks', lua_version = '5.4' },
    { 'prettierd', pkg = '@fsouza/prettierd', manager = 'bun' },
    {
      'stylua',
      pkg = 'https://github.com/johnnymorganz/stylua',
      manager = 'bin',
      bin_name = 'stylua',
    },
    {
      'cljfmt',
      pkg = 'https://github.com/weavejester/cljfmt',
      manager = 'bin',
      bin_name = 'cljfmt',
    },
    {
      'tree-sitter-cli',
      pkg = 'https://github.com/tree-sitter/tree-sitter',
      manager = 'bin',
      bin_name = 'tree-sitter',
    },
  },
}

---@param tool_type 'lsp'|'others'
---@return string[]
local function get_necessary_tools(tool_type) return tools[tool_type] end

return get_necessary_tools
