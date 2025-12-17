return {
  'stevearc/conform.nvim',
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
      css = { 'prettier' },
    },
  },
}
