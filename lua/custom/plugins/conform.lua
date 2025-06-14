return {
  'stevearc/conform.nvim',
  opts = {
    formatters = {
      topiary_nushell = {
        command = os.getenv 'SCRIPTS_FOLDER' .. '/bin/format.nu',
      },
    },
    formatters_by_ft = {
      nu = { 'topiary_nushell' },
    },
  },
}
