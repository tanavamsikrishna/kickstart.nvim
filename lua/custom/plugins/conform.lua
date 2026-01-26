return {
  'stevearc/conform.nvim',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  opts = {
    formatters = {
      topiary_nushell = {
        command = os.getenv 'SCRIPTS_FOLDER' .. '/bin/format.nu',
      },
      json5 = {
        command = 'json5',
        args = { '--space', '2' },
      },
      dockerfmt = {
        command = 'dockerfmt',
      },
    },
    formatters_by_ft = {
      nu = { 'topiary_nushell' },
      python = { 'ruff_organize_imports', 'ruff_format' },
      json = { 'jq' },
      json5 = { 'json5' },
      dockerfile = { 'dockerfmt' },
      yaml = { 'yamlfmt' },
      css = { 'prettierd' },
      html = { 'prettierd' },
    },
  },
  config = function(_, opts)
    require('mason').setup()
    require('mason-tool-installer').setup { ensure_installed = { 'prettierd' } }
    require('conform').setup(opts)
  end,
}
