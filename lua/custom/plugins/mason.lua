return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
  },
  config = function()
    local skipped_lsp_servers = { 'nushell' }
    local formatting_tools = { 'stylua', 'prettierd', 'jq' }

    -- 1. Scan lsp/ folder for server names
    local lsp_server_tools = {}
    for name, type in vim.fs.dir(vim.fn.stdpath 'config' .. '/lsp') do
      if type == 'file' and name:match '%.lua$' then
        table.insert(lsp_server_tools, (name:gsub('%.lua$', '')))
      end
    end

    local tools_needed = lsp_server_tools
    vim.list_extend(tools_needed, formatting_tools)
    tools_needed = vim.tbl_filter(function(key)
      return not vim.tbl_contains(skipped_lsp_servers, key)
    end, tools_needed)

    -- Fix for workspace not loading with luals:v3.17.1
    tools_needed = vim.tbl_filter(function(key)
      return not vim.tbl_contains({ 'lua_ls' }, key)
    end, tools_needed)
    vim.list_extend(tools_needed, { { 'lua_ls', version = '3.16.4' } })

    require('mason-tool-installer').setup { ensure_installed = tools_needed }

    ---@module 'mason-lspconfig.settings'
    ---@type MasonLspconfigSettings
    local mason_lspconfig_opts = {
      -- explicitly set to an empty table
      -- (Kickstart populates installs via mason-tool-installer)
      ensure_installed = {},
      automatic_enable = { exclude = { 'stylua' } },
    }
    require('mason-lspconfig').setup(mason_lspconfig_opts)
  end,
}
