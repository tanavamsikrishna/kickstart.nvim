return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim', -- This lets mason-tool-installer use the lsp names of mason tools
  },
  config = function()
    local installation_skipped = require 'custom.config.required_tools' 'installation_skipped'
    local other_tools = require 'custom.config.required_tools' 'others'
    local lsp_servers = require 'custom.config.required_tools' 'lsp'

    local tools_needed = lsp_servers
    vim.list_extend(tools_needed, other_tools)
    tools_needed = vim.tbl_filter(function(key) return not vim.tbl_contains(installation_skipped, key) end, tools_needed)

    require('mason-tool-installer').setup { ensure_installed = tools_needed, auto_update = true }
  end,
}
