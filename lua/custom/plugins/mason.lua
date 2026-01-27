return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
  },
  config = function()
    local lsp_servers = require 'custom.config.lsp_server_list'
    local formatting_tools = { 'stylua', 'prettierd', 'jq' }
    local skip_installation = { 'nushell' }

    -- Ensure the servers and tools above are installed
    --
    -- To check the current status of installed tools and/or manually install
    -- other tools, you can run
    --    :Mason
    --
    -- You can press `g?` for help in this menu.
    --
    -- `mason` had to be setup earlier: to configure its options see the
    -- `dependencies` table for `nvim-lspconfig` above.
    --
    -- You can add other tools here that you want Mason to install
    -- for you, so that they are available from within Neovim.
    local ensure_installed = vim.tbl_keys(lsp_servers or {})
    ensure_installed = vim.list_extend(ensure_installed, formatting_tools)
    ensure_installed = vim.tbl_filter(function(key)
      return not vim.tbl_contains(skip_installation, key)
    end, ensure_installed)

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

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
