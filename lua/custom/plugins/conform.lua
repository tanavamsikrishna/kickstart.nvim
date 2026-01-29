---@module 'conform'
---@type conform.setupOpts
local opts = {
  notify_on_error = true,
  format_on_save = {
    lsp_format = 'fallback',
  },
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
    css = { 'prettierd' },
    dockerfile = { 'dockerfmt' },
    fish = { 'fish_indent' },
    html = { 'prettierd' },
    javascript = { 'prettierd' },
    json = { 'prettierd' },
    json5 = { 'json5' },
    lua = { 'stylua' },
    nu = { 'topiary_nushell' },
    python = { 'ruff_organize_imports', 'ruff_format' },
    toml = { 'taplo' },
    yaml = { 'yamlfmt' },
  },
  stop_after_first = true,
}

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = opts,
}
